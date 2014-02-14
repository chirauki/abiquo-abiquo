class abiquo::apache inherits abiquo {
  file { '/etc/httpd/conf.d/abiquo.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/abiquo/abiquo.conf',
    notify  => Service['httpd'],
    require => Package['abiquo-ui']
  }

  file { '/etc/httpd/conf.d/proxy_ajp.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/abiquo/proxy_ajp.conf',
    notify  => Service['httpd'],
    require => Package['abiquo-ui']
  }

  file { '/opt/abiquo/tomcat/conf/server.xml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/abiquo/server.xml',
    notify  => Service['abiquo-tomcat'],
    require => [ Package['abiquo-api'], Package['abiquo-ui'] ]
  }

  package { "httpd":
    ensure  => latest,
    require => Yumrepo['Abiquo-Base'],
    notify  => [ Service['httpd'], Package['abiquo-ui'] ]
  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
    require => [ Package['httpd'], File['/etc/httpd/conf.d/abiquo.conf', '/etc/httpd/conf.d/proxy_ajp.conf', '/opt/abiquo/tomcat/conf/server.xml'] ]
  }
}