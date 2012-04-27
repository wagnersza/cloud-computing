node basenode {
  # exec { "route add -net 10.2.45.0 netmask 255.255.255.0 gw 10.10.10.1 eth1":
  #         unless => 'netstat -nrv | grep -e "10.2.45.0.*10.10.10.1"',
  # }
  # 
  # exec { "route add -net 192.168.0.0 netmask 255.255.255.0 gw 10.10.10.1 eth1":
  #         unless => 'netstat -nrv | grep -e "192.168.0.0.*10.10.10.1"',
  # }

}

node novaservices inherits basenode {
   include role_novaservices
}

node novacompute inherits basenode {
   include role_novacompute
}

node devstack inherits basenode {
   include role_devstack
}

node tools inherits basenode {
   include role_yum
}