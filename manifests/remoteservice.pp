class abiquo::remoteservice (
  $abiquo_versio  = $abiquo::params::abiquo_version,
  $rstype         = $abiquo::params::rstype,
  $apiaddress     = $abiquo::params::apiaddress
) {
  include abiquo::jdk
  include abiquo::redis
  
  if versioncmp($abiquo_version, "2.7") <= 0 {
    $rspackages = $rstype ? {
      publiccloud  => ["abiquo-vsm", "abiquo-virtualfactory", "abiquo-nodecollector" ],
      datacenter   => ["abiquo-vsm", "abiquo-virtualfactory", "abiquo-nodecollector", "abiquo-ssm", "abiquo-am"]
    }
  }
  else {
    $rspackages = $rstype ? {
      publiccloud => ["abiquo-vsm", "abiquo-virtualfactory", "abiquo-nodecollector", "abiquo-cpp"],
      datacenter  => ["abiquo-vsm", "abiquo-virtualfactory", "abiquo-nodecollector", "abiquo-ssm", "abiquo-am"]
    }
  }

  package { $rspackages:
    ensure  => latest,
    require => [ Yumrepo['Abiquo-Rolling'], Package['redis'] ],
    notify  => Service['abiquo-tomcat']
  }

  $rabbitaddress = defined(Package['abiquo-api']) ? {
    false => $apiaddress,
    true  => $::ipaddress,
  }

  file { '/opt/abiquo/config':
    ensure  => directory,
    owner   => 'root',
    mode    => '0755',
    require => Package[$rspackages]
  }

  abiproperties::register { 'Server properties for RS':
    content => template("abiquo/properties.${rstype}.erb"),
    order   => '02',
    require => [ Package["abiquo-vsm"], File['/opt/abiquo/config'] ],
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