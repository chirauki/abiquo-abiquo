class abiquo::zookeeper {
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