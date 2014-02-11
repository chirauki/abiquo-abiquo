class abiquo::api::install inherits abiquo::api {
  package { $apipkgs:
    ensure  => present,
    require => Yumrepo['Abiquo-Base']
  }

  exec { 'Abiquo database schema':
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command => 'mysql < /usr/share/doc/abiquo-server/database/kinton-schema.sql',
    unless  => 'mysql -e "show databases" | grep kinton',
    require => Package['abiquo-server']
  }

  abiproperties::register { 'Server properties for API':
    content => template('abiquo/properties.server.erb'),
    order   => '02',
    require => Package['abiquo-server']
  }

  service { "abiquo-tomcat":
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "java.*/opt/abiquo/tomcat",
    require   => [ Package[$apipkgs], Exec['Abiquo database schema'], Concat['/opt/abiquo/config/abiquo.properties'] ]
  }
}