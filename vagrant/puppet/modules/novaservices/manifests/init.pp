class novaservices::init {
  
  include novaservices::glance
  include novaservices::nova
  include novaservices::swift
  
}

