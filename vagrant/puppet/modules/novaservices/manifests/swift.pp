class novaservices::swift inherits novaservices::baseos {
  ##Handle Debian based systems
  if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {

  } 

  ## Handle RedHat derivatives      
  else {
    if ($operatingsystem == redhat) or ($operatingsystem == centos) or ($operatingsystem == fedora) {
   
    }
  }  
}