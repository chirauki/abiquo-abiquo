class { 'abiquo::client': 
  secure        => true,
  ui_custom     => {}
  api_address   => $::ipaddress,
  api_endpoint  => $::ipaddress
}