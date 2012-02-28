# Define: remote_rpm
#
# Define remote_rpm
#
# Author: Wagner Souza (wagnersza@gmail.com)
#
define remote_rpm ($host,$package,$path = "/tmp"){

  # exec { "wget_file":
  #   command => "wget -q -O $path/$package $host/$package",
  #   onlyif => "test ! -f $path/$package",
  # }
  
  exec { "get_file":
    command => "curl -s ${host}/${package} > ${path}/${package}",
    onlyif => "test ! -f ${path}/${package}",
  }
  

  #   package {"${package}":
  #   provider => yum,
  #   source => "${path}",
  #   require => [ Exec["wget_file"] ],   
  # }
}