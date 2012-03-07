class novaservices::packages {

  ##Handle Debian based systems
  if ($operatingsystem == debian) or ($operatingsystem == ubuntu) { 
     
    # Create source list file
    file { "/etc/apt/sources.list":
      ensure => present,
      owner => root,
      group => root,
      content => template("novaservices/sources.list.erb"),
    }
  
    # Update apt whenever the sources file changes
    exec { "apt-get_update":
      command => "/usr/bin/apt-get update",
      subscribe => File["/etc/apt/sources.list"],
      refreshonly => true,
      # require => 
    }
  
    exec { "apt-get_upgrade":
      command => "/usr/bin/apt-get upgrade; touch /var/run/upgrade.lock", 
      onlyif => "test ! -f /var/run/upgrade.lock",
      require =>  Exec["apt-get_update"],
    }
  
    exec { "add_repo_glance-core":
      command => "add-apt-repository ppa:glance-core/trunk; /usr/bin/apt-get update; touch /var/run/glance.lock",
      onlyif => "test ! -f /var/run/glance.lock",
      require => Package["python-software-properties"]
    }
  
    package { "python-software-properties":
      ensure => latest,
    }
    
    # List of packages to be installed
    $base_packages = [
      "bridge-utils",
      "ntp",
      "mysql-server",
      "glance",
      "vim",
      "rabbitmq-server",
      "python-nova",
      "nova-common",
      "nova-doc",
      "nova-api",
      "nova-network",
      "nova-objectstore",
      "nova-scheduler",
      "nova-compute",
      "euca2ools",
      "unzip",
      # "lvm2",
      "nova-volume",
      "iscsitarget",
      "iscsitarget-dkms",
      # "python-greenlet",
      # "python-mysqldb",        
    ]
  
    package { $base_packages:
      ensure => latest,
      require =>  Exec["add_repo_glance-core"]
    }
  
  } 
  
  ## Handle RedHat derivatives
  else {
    if ($operatingsystem == redhat) or ($operatingsystem == centos) or ($operatingsystem == fedora) {
    
      # # Create source list file
      file { "/etc/yum.repos.d/gd-openstack.repo":
        ensure => present,
        owner => root,
        group => root,
        content => template("novaservices/gd-openstack.repo.erb"),
      }
      # 
      # # Update apt whenever the sources file changes
      # exec { "apt-get_update":
      #   command => "/usr/bin/apt-get update",
      #   subscribe => File["/etc/apt/sources.list"],
      #   refreshonly => true,
      #   # require => 
      # }
      # 
      # exec { "apt-get_upgrade":
      #   command => "/usr/bin/apt-get upgrade; touch /var/run/upgrade.lock", 
      #   onlyif => "test ! -f /var/run/upgrade.lock",
      #   require =>  Exec["apt-get_update"],
      # }
      # 
      exec { "add_repo_epel":
        command => "rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm ; touch /var/run/add_repo_epel.lock",
        onlyif => "test ! -f /var/run/add_repo_epel.lock",
      }

      # List of packages to be installed
      $base_packages = [
        "bridge-utils",
        "ntp",
        "mysql-server",
        "mysql",
        "openstack-nova-node-full",
        # "glance",
        # "rabbitmq-server",
        # "python-nova",
        # "nova-common",
        # "nova-doc",
        # "nova-api",
        # "nova-network",
        # "nova-objectstore",
        # "nova-scheduler",
        # "nova-compute",
        # "nova-volume",
        "euca2ools",
        "unzip",
        "lvm2",
        "python-novaclient",
        "MySQL-python",
        # "iscsitarget",
        # "iscsitarget-dkms",
        # "python-greenlet",
        # "python-mysqldb",        
      ]

      package { $base_packages:
        ensure => latest,
        require =>  [ Exec["add_repo_epel"], File["/etc/yum.repos.d/gd-openstack.repo"] ]
      }     
    
    }
  }    
}