class abiquo::remoteservice::update inherits abiquo::remoteservice {      
  package { $rspackages:
    ensure  => latest,
    require => Yumrepo['Abiquo-Base'],
    notify  => Service['abiquo-tomcat']
  }

  abiproperties::register { 'Server properties for RS':
    content => template("abiquo/properties.${rstype}.erb"),
    order   => '02',
    require => Package["abiquo-vsm"],
    notify  => Service["abiquo-tomcat"]
  }

  if ! defined(Service['abiquo-tomcat']) {
    service { 'abiquo-tomcat':
      ensure  => running,
      enable  => true,
      require => [ Service['redis'], Concat['/opt/abiquo/config/abiquo.properties'] ]
    }
  }
}