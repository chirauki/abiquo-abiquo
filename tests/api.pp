class { 'abiquo::api':
  secure          => true,
  proxy           => false,
  proxyhost       => '',
  install_db      => true,
  install_rabbit  => true,
  install_redis   => true,
  db_url          => '',
  db_user         => 'root',
  db_pass         => ''
}
