class yum::packages {  

  # List of packages to be installed
  $base_packages = [
    # "git",
    # "vim",
  ]

  package { $base_packages:
    ensure => latest,
  }

}