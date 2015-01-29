class abiquo::monitoring::cassandra {
  yumrepo { "datastax":
    ensure   => present,
    name     => "datastax",
    descr    => "datastax",
    baseurl  => "http://rpm.datastax.com/community",
    gpgcheck => 0,
    enabled  => true
  }

  package { [ 'java-1.7.0-openjdk', 'cassandra20' ]:
    ensure  => present,
    require => Yumrepo['datastax']
  }

  service { 'cassandra':
    ensure  => running,
    enable  => true,
    require => Package['cassandra20']
  }
}