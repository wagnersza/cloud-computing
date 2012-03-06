class novaservices::glance inherits novaservices::baseos {
  
  ##Handle Debian based systems
  if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {  
    
    exec { "mysql_create_glance_db":
      command => "mysql -uroot -pmygreatsecret -e 'CREATE DATABASE glance;' ; touch /var/run/mysqlpassdb.lock",
      onlyif => "test ! -f /var/run/mysqlpassdb.lock",
      require =>  Service["mysql"],
    }

    exec { "mysql_create_glance_username":
      command => "mysql -uroot -pmygreatsecret -e 'CREATE USER glancedbadmin;' ; touch /var/run/mysqluser.lock",
      onlyif => "test ! -f /var/run/mysqluser.lock",
      require =>  Exec["mysql_create_glance_db"],
    }

    exec { "mysql_grant_privileges_glance_username":
      command => "mysql -uroot -pmygreatsecret -e \"GRANT ALL PRIVILEGES ON glance.* TO 'glancedbadmin'@'%' ;\" ; touch /var/run/mysqlgrant.lock",
      onlyif => "test ! -f /var/run/mysqlgrant.lock",
      require =>  Exec["mysql_create_glance_username"],
    }

    exec { "mysql_create_passwd_glance_username":
      command => "mysql -uroot -pmygreatsecret -e \"SET PASSWORD FOR 'glancedbadmin'@'%' = PASSWORD('glancesecret');\" ; touch /var/run/mysqlpassuser.lock",
      onlyif => "test ! -f /var/run/mysqlpassuser.lock",
      require =>  Exec["mysql_grant_privileges_glance_username"],
    }

    service { "glance-registry":
      enable    => true,
      ensure    => running,
      require =>  Package["glance"],
      hasrestart => true,    
    }

    file { "/etc/glance/glance-registry.conf":
      notify => Service["glance-registry"],
      ensure => present,
      owner => root,
      group => root,
      content => template("novaservices/glance-registry.conf.erb"),
      require =>  Package["glance"],
    }
  } 
  ## Handle RedHat derivatives
  else {
    if ($operatingsystem == redhat) or ($operatingsystem == centos) or ($operatingsystem == fedora) {
  
    }
  }
}