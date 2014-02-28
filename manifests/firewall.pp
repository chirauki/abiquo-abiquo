class abiquo::firewall inherits abiquo {
  Firewall {
    before  => Class['abiquo::firewall::post'],
    require => Class['abiquo::firewall::pre'],
  }

  class { ['abiquo::firewall::pre', 'abiquo::firewall::post']: }
  ->
  resources { "firewall": purge => true }

  firewall { '100 allow http and https access':
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }->
  firewall { '100 allow ssh access':
    port   => 22,
    proto  => tcp,
    action => accept,
  }
}