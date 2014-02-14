class abiquo::mariadb inherits abiquo {
  package { ["postfix", "mysql-libs"]:
    ensure => purged,
  }

  package { [ "MariaDB-server", "MariaDB-client" ]:
    ensure  => latest,
    require => [ Yumrepo['Abiquo-Base'], Package["postfix"] ]
  }

  service { 'mysql':
    ensure  => running,
    enable  => true,
    require => Package['MariaDB-server']
  }
}