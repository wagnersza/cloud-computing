class novaservices::nova inherits novaservices::baseos {

  ##Handle Debian based systems
  if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {
    
    exec { "mysql_create_nova_db":
      command => "mysql -uroot -pmygreatsecret -e 'CREATE DATABASE nova;' ; touch /var/run/mysql_create_nova_db.lock",
      onlyif => "test ! -f /var/run/mysql_create_nova_db.lock",
      require =>  Service["mysql"],
    }
  
    exec { "mysql_create_nova_username":
      command => "sudo mysql -uroot -pmygreatsecret -e 'CREATE USER novadbadmin;' ; touch /var/run/mysql_create_nova_username.lock",
      onlyif => "test ! -f /var/run/mysql_create_nova_username.lock",
      require =>  Exec["mysql_create_nova_db"],
    }

    exec { "mysql_grant_privileges_nova_username":
      command => "mysql -uroot -pmygreatsecret -e \"GRANT ALL PRIVILEGES ON nova.* TO 'novadbadmin'@'%' ;\" ; touch /var/run/mysql_grant_privileges_nova_username.lock",
      onlyif => "test ! -f /var/run/mysql_grant_privileges_nova_username.lock",
      require =>  Exec["mysql_create_nova_username"],
    }

    exec { "mysql_create_passwd_nova_username":
      command => "mysql -uroot -pmygreatsecret -e \"SET PASSWORD FOR 'novadbadmin'@'%' = PASSWORD('novasecret');\" ; touch /var/run/mysql_create_passwd_nova_username.lock",
      onlyif => "test ! -f /var/run/mysql_create_passwd_nova_username.lock",
      require =>  Exec["mysql_grant_privileges_nova_username"],
    }

    file { "/etc/default/iscsitarget":
      notify => Service["iscsitarget"],
      ensure => present,
      owner => root,
      group => root,
      content => template("novaservices/iscsitarget.erb"),
      require =>  Package["iscsitarget"],
    }
  
    service { "iscsitarget":
      enable    => true,
      ensure    => running,
      require =>  Package["iscsitarget"],
      hasrestart => true,    
    }
  
    file { "/etc/nova/nova.conf":
      # notify => Service["$nova_services"],
      ensure => present,
      owner => root,
      group => nova,
      mode => 644,
      content => template("novaservices/nova.conf.erb"),
      require =>  Package["nova-common"],
    }
  
    $nova_services = [
    "libvirt-bin",
    "nova-network",
    "nova-compute",
    "nova-api",
    "nova-objectstore",
    "nova-scheduler",
    "nova-volume",
    "glance-api",
     ]  
  
    service { $nova_services:
      subscribe => Exec["nova-manage_create_proj"],
      enable    => true,
      ensure    => running,
      require =>  File["/etc/nova/nova.conf"],
      hasrestart => true,    
    }
  
    exec { "nova-manage_db_sync":
      command => "nova-manage db sync ; touch /var/run/nova-manage_db_sync.lock" ,
      onlyif => "test ! -f /var/run/nova-manage_db_sync.lock",
      require =>  Exec["mysql_create_passwd_nova_username"],
    }
  
    exec { "nova-manage_network_create":
      command => "nova-manage network create private 192.168.4.0/24 1 256 ; touch /var/run/nova-manage_network_create.lock" ,
      onlyif => "test ! -f /var/run/nova-manage_network_create.lock",
      require =>  Exec["nova-manage_db_sync"],
    }
  
    exec { "nova-manage_floating_create":
      command => "nova-manage floating create --ip_range=10.10.10.224/27 ; touch /var/run/nova-manage_floating_create.lock" ,
      onlyif => "test ! -f /var/run/nova-manage_floating_create.lock",
      require =>  Exec["nova-manage_network_create"],
    }
  
    exec { "nova-manage_create_user":
      command => "nova-manage user admin novaadmin ; touch /var/run/nova-manage_create_user.lock" ,
      onlyif => "test ! -f /var/run/nova-manage_create_user.lock",
      require =>  Exec["nova-manage_floating_create"],
    }
  
    exec { "nova-manage_create_proj":
      command => "nova-manage project create proj novaadmin ; touch /var/run/nova-manage_create_proj.lock" ,
      onlyif => "test ! -f /var/run/nova-manage_create_proj.lock",
      require =>  Exec["nova-manage_create_user"],
    }
  
    file { '/home/localadmin':
        owner => root,
        group => nova,
        mode => 755,
        ensure => directory,
        recurse => true,
        require =>  Package["nova-common"],
    }

    file { '/home/localadmin/creds':
        owner => nova,
        group => nova,
        mode => 755,
        ensure => directory,
        recurse => true,
        require => File["/home/localadmin"],
    }

    exec { "nova-manage_zip_proj":
      command => "nova-manage project zipfile proj novaadmin /home/localadmin/creds/novacreds.zip ; touch /var/run/nova-manage_zip_proj.lock" ,
      onlyif => "test ! -f /var/run/nova-manage_zip_proj.lock",
      require =>  File["/home/localadmin/creds"],
    }

    exec { "nova-manage_unzip_creds":
      command => "unzip novacreds.zip; touch /var/run/nova-manage_unzip_creds.lock",
      cwd => "/home/localadmin/creds",
      onlyif => "test ! -f /var/run/nova-manage_unzip_creds.lock",
      require =>  File["/home/localadmin/creds"],
    }

    exec { "nova-manage_user_exports":
      command => "nova-manage user exports novaadmin ; touch /var/run/nova-manage_user_exports.lock" ,
      onlyif => "test ! -f /var/run/nova-manage_user_exports.lock",
      require =>  Exec["nova-manage_unzip_creds"],
    }
    
    file { '/home/localadmin/creds/novarc':
      content => template("novaservices/novarc.erb"),
      owner => nova,
      group => nova,
      mode => 755,
      recurse => true,
      require => File["/home/localadmin/creds"],
    }
  } 

  ## Handle RedHat derivatives
  else {
    if ($operatingsystem == redhat) or ($operatingsystem == centos) or ($operatingsystem == fedora) {

  }
    
}

# Coisas que ainda não coloquei para rodar pelo puppet
#vagrant@novaservices:/home/localadmin$ sudo dd if=/dev/zero of=/home/localadmin/nova-volumes bs=100M count=10
#losetup --show -f /home/localadmin/nova-volumes
#vgcreate nova-volumes /dev/loop0
