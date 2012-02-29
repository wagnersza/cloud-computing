node basenode {
	exec { "route add -net 10.2.0.0 netmask 255.255.0.0 gw 192.168.0.1 eth1":
	        unless => 'netstat -nrv | grep -e "10.2.0.0.*192.168.0.1"',
	}
}

node nova01 inherits basenode {
  include role_nova
}
