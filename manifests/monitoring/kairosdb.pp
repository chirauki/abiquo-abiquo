class abiquo::monitoring::kairosdb {
  include abiquo::firewall

  firewall { '100 allow kairosdb http access':
    port   => 8080,
    proto  => tcp,
    action => accept,
  }

  package { 'kairosdb':
    ensure    => installed,
    provider  => 'rpm',
    source    => 'http://dl.bintray.com/brianhks/generic/kairosdb-0.9.3-2.rpm'
  }

  service { 'kairosdb':
    ensure  => 'running',
    enable  => true,
    require => Package['kairosdb']
  }

  file { '/opt/kairosdb/conf/kairosdb.properties':
    ensure  => present,
    source  => 'puppet:///modules/abiquo/monitoring/kairosdb.properties',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['kairosdb'],
    notify  => Service['kairosdb']
  }
}