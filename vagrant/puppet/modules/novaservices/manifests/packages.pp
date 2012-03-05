class novaservices::packages {
  
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