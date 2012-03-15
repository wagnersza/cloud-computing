class devstack::base inherits devstack::packages {  

  file { "install_script":
    path => "/home/vagrant/install_devstack.sh",
    ensure => present,
    content => template("devstack/install_devstack.sh.erb"),
    mode => 755,
    # require =>  Package["mysql-server"],
  }
  
  # exec { "roda_script":
  #   command => "/usr/bin/apt-get update; git clone https://github.com/cloudbuilders/devstack.git; echo ADMIN_PASSWORD=password > localrc; echo MYSQL_PASSWORD=password >> localrc; echo RABBIT_PASSWORD=password >> localrc; echo SERVICE_TOKEN=tokentoken >> localrc; echo FLAT_INTERFACE=br100 >> localrc; cd devstack; ./stack.sh",
  # }    
  
}

