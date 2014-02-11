class abiquo::client::install inherits abiquo::client {
  package { $uipkg:
    ensure  => present,
    require => [ Yumrepo['Abiquo-Base'], Package['abiquo-api'] ],
    notify  => Service['abiquo-tomcat']
  }
}