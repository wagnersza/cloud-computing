node sandbox inherits basenode {
	$zone = "sandbox"
	$puppet_master = "puppet.local.com"
	#include user::puppet
	exec { "route add -net 10.2.0.0 netmask 255.255.0.0 gw 192.168.0.1 eth1":
	        unless => 'netstat -nrv | grep -e "10.2.0.0.*192.168.0.1"',
	}
}

# node puppetmaster inherits sandbox {
#         
#     $puppetmaster_passwd = '$1$6FlrakZW$7P7npg/7rbgAt2r8hrJvC0'
#     $puppetmaster_local_ipbind = '33.33.33.33'
#     
#     include role_puppetmaster
# }
