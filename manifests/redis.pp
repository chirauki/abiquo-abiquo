class abiquo::redis {
  user { 'redis':
    ensure  => present,
    require => Yumrepo['Abiquo-Base']
  }

  file { '/var/log/redis/redis.log':
    ensure  => present,
    recurse => true,
    owner   => 'redis',
    mode    => '0755',
    require => User['redis']
  }

  file { '/var/lib/redis':
    ensure  => directory,
    recurse => true,
    owner   => 'redis',
    mode    => '0755',
    require => User['redis']
  }

  package { "redis":
    ensure  => latest,
    require => [ Yumrepo['Abiquo-Base'], File['/var/lib/redis'] ]
  }

  service { 'redis':
    ensure  => running,
    enable  => true,
    require => Package['redis']
  }
}