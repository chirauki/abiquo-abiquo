class abiquo::zookeeper {
  include abiquo::ntp

  firewall { '100 allow zookeeper access':
    port   => 8081,
    proto  => tcp,
    action => accept,
  }

  package { 'zookeeper':
    ensure  => installed,
    require => Yumrepo['abiquo-base']
  }

  service { "zookeeper":
    ensure  => running,
    enable  => true,
    require => Package['zookeeper']
  }
}