class abiquo::remoteservice::install inherits abiquo::remoteservice {
  package { $rspackages:
    ensure  => present,
    require => Yumrepo['Abiquo-Base']
  }

  abiproperties::register { 'Server properties for RS':
    content => template("abiquo/properties.${rstype}.erb"),
    order   => '02',
    require => Package['abiquo-vsm'],
    notify  => Service['abiquo-tomcat']
  }

  if ! defined(Service['abiquo-tomcat']) {
    service { "abiquo-tomcat":
      ensure    => running,
      enable    => true,
      hasstatus => false,
      pattern   => "java.*/opt/abiquo/tomcat",
      require   => [ Package[$rspkgs], Concat['/opt/abiquo/config/abiquo.properties'] ]
    }
  }
}