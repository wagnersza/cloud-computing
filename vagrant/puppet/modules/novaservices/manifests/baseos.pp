class novaservices::baseos inherits novaservices::packages {
  
  ##Handle Debian based systems
  if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {  
    
    # ntp
    file { "/etc/ntp.conf":
      ensure => present,
      owner => root,
      group => root,
      content => template("novaservices/ntp.conf.erb"),
      require => Package["ntp"],
    }
  
    service { "ntp":
      enable    => true,
      ensure    => running,
      require => File["/etc/ntp.conf"],    
      hasrestart => true,
    }
  
    # mysql
    file { "/etc/mysql/my.cnf":
      ensure => present,
      owner => root,
      group => root,
      content => template("novaservices/my.cnf.erb"),
      require =>  Package["mysql-server"],
    }
  
    service { "mysql":
      enable    => true,
      ensure    => running,
      require => File["/etc/mysql/my.cnf"],
      hasrestart => true,    
    }
  
    exec { "mysql_change_root_passwd":
      command => "/usr/bin/mysqladmin -u root password 'mygreatsecret'; touch /var/run/mysqlpass.lock",
      onlyif => "test ! -f /var/run/mysqlpass.lock",
      require =>  Service["mysql"],
    }
  } 
  
  ## Handle RedHat derivatives
  else {
    if ($operatingsystem == redhat) or ($operatingsystem == centos) or ($operatingsystem == fedora) {
  }
}