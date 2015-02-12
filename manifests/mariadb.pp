class abiquo::mariadb {
  package { [ 'MariaDB-server', 'MariaDB-client' ]:
    ensure  => latest,
    require => Yumrepo['Abiquo-Base']
  }

  service { 'mysql':
    ensure  => running,
    enable  => true,
    require => Package['MariaDB-server']
  }
}