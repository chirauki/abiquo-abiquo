class abiquo::client::update inherits abiquo::client {
  package { $uipkg:
    ensure  => latest,
    require => [ Yumrepo['Abiquo-Base'], Package['abiquo-api'] ],
    notify  => Service['abiquo-tomcat']
  }

  if $uipkg == "abiquo-ui" {
    exec { 'Remove old client-premium':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => "yum remove abiquo-client-premium",
      onlyif  => "test -d /opt/abiquo/tomcat/client-premium"
    }
  }
}