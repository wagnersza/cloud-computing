# Class: managed_interface
#
# This class maintains the specified interface configuration
#
# Parameters:
#   $device
#       The name of the network device (e.g. eth0/sit0/ppp0)
#
#   $ipaddr
#       The IP address to assign to the interface
#
#   $netmask
#       The Subnet Mask which should be assigned to the interface
#
#   $up
#       Should the interface come up on boot? (optional)
#
#   $network
#       The address for the start of this subnet (optional)
#
#   $hwaddr
#       The MAC Address for the ethernet device (optional)
#
#   $gateway
#       The default gateway to be configured. Remember that only the last configured gateway will be used. (optional)
#
# Actions:
#   Ensures that the appropriate python libraries are installed and ensures that the correct source code revisions are installed via git
#
# Sample Usage:
#
#   managed_interface{ "lo":
#       device  => "lo",
#       ipaddr  => "127.0.0.1",
#       netmask => "255.0.0.0",
#       hwaddr  => "00:1d:09:fa:93:6a",
#       up  => true,
#   }
#
define managed_interface($device, $ipaddr, $netmask, $up=true, $network="", $hwaddr="",$gateway="") {

    ##
    ## Handle RedHat derivatives
    ##
    if ($operatingsystem == redhat) or ($operatingsystem == centos) or ($operatingsystem == fedora) {
        if ($up) {
            $onBoot = "yes"
        } else {
            $onBoot = "no"
        }

        augeas { "main-$device":
            context => "/files/etc/sysconfig/network-scripts/ifcfg-$device",
            changes => [
                "set DEVICE $device",
                "set BOOTPROTO none",
                "set ONBOOT $onBoot",
                "set NETMASK $netmask",
                "set IPADDR $ipaddr",
            ],
        }

        if ($network!="") {
            augeas { "network-$device":
                context => "/files/etc/sysconfig/network-scripts/ifcfg-$device",
                changes => [
                    "set NETWORK $network",
                ],
            }
        }

        if ($hwaddr!="") {
            augeas { "mac-$device":
                context => "/files/etc/sysconfig/network-scripts/ifcfg-$device",
                changes => [
                    "set HWADDR $hwaddr",
                ],
            }
        }

        if ($gateway!="") {
            augeas { "gateway-$device":
                context => "/files/etc/sysconfig/network",
                changes => [
                    "set GATEWAY $gateway",
                ],
            }
        }

        if $up {
            exec {"ifup-$device":
                command => "/sbin/ifup $device",
                unless  => "/sbin/ifconfig | grep $device",
                require => Augeas["main-$device"],
            }
        } else {
            exec {"ifdown-$device":
                command => "/sbin/ifconfig $device down",
                onlyif  => "/sbin/ifconfig | grep $device",
            }
        }
    ##
    ## Handle Debian based systems
    ##
    } else {
        if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {
            augeas { "main-$device" :
                context => "/files/etc/network/interfaces",
                changes => [
                    "set auto[child::1 = '$device']/1 $device",
                    "set iface[. = '$device'] $device",
                    "set iface[. = '$device']/family inet",
                    "set iface[. = '$device']/method static",
                    "set iface[. = '$device']/address $ipaddr",
                    "set iface[. = '$device']/netmask $netmask",
                ],
            }

            if ($hwaddr!="") {

                augeas { "mac-$device" :
                    context => "/files/etc/network/interfaces",
                    changes => [
                        "set iface[. = '$device']/hwaddress $hwaddr",
                    ],
                    require => Augeas["main-$device"],
                }
            }

            if ($network!="") {

                augeas { "network-$device" :
                    context => "/files/etc/network/interfaces",
                    changes => [
                        "set iface[. = '$device']/network $network",
                    ],
                    require => Augeas["main-$device"],
                }
            }

            if ($gateway!="") {

                augeas { "network-$device" :
                    context => "/files/etc/network/interfaces",
                    changes => [
                        "set iface[. = '$device']/gateway $gateway",
                    ],
                    require => Augeas["main-$device"],
                }
            }       

            if $up {
                exec {"/sbin/ifup $device":
                    command => "/sbin/ifup $device",
                    unless  => "/sbin/ifconfig | grep $device",
                }
            } else {
                exec {"/sbin/ifdown $device":
                    command => "/sbin/ifconfig $device down",
                    onlyif  => "/sbin/ifconfig | grep $device",
                }
            }
        }
    }
}