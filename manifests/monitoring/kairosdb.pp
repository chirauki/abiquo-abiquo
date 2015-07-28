class abiquo::monitoring::kairosdb {
  firewall { '100 allow kairosdb http access':
    port   => 8080,
    proto  => tcp,
    action => accept,
  }

  package { 'kairosdb':
    ensure   => installed,
    provider => 'rpm',
    source   => 'https://github.com/kairosdb/kairosdb/releases/download/v0.9.4/kairosdb-0.9.4-6.rpm'
  }

  service { 'kairosdb':
    ensure    => 'running',
    enable    => true,
    hasstatus => false,
    pattern   => 'java.*org.kairosdb.core.Main*',
    require   => Package['kairosdb']
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
