class abiquo::client inherits abiquo {
  include abiquo::jdk
  
  if versioncmp($abiquo_version, "2.7") <= 0 {
    $uipkg = 'abiquo-client-premium'
  }
  else {
    notify { "Abiquo version ${abiquo_version} does not use flex client. Selecting abiquo-ui instead.": }
    $uipkg = "abiquo-ui"
  }

  package { $uipkg:
    ensure  => latest,
    require => [ Yumrepo['Abiquo-Rolling'], Package['jdk'] ],
    notify  => Service['abiquo-tomcat']
  }

  if $uipkg == "abiquo-ui" {
    include abiquo::apache
    
    exec { 'Remove old client-premium':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => "yum remove abiquo-client-premium",
      onlyif  => "test -d /opt/abiquo/tomcat/client-premium"
    }
    
    exec { 'replace API location in ui config':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => "sed -i 's/localhost/${::ipaddress}/g' /var/www/html/ui/config/client-config.json",
      onlyif  => "grep localhost /var/www/html/ui/config/client-config.json",
      require => Package['abiquo-ui']
    }
  }
}