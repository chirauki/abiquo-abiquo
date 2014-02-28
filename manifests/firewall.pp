class abiquo::firewall inherits abiquo {
  resources { "firewall":
    purge => true
  }

  Firewall {
    before  => Class['abiquo::firewall::post'],
    require => Class['abiquo::firewall::pre'],
  }

  class { ['abiquo::firewall::pre', 'abiquo::firewall::post']: }

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