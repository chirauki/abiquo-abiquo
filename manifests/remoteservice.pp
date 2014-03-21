class abiquo::remoteservice (
  $abiquo_version = "2.9",
  $rstype         = "publiccloud",
  $api_address    = "localhost"
) {
  include abiquo::jdk
  include abiquo::redis
  include abiquo::firewall

  if ! defined(Class['abiquo']) {
    class { 'abiquo': 
      abiquo_version => $abiquo_version
    }
  }
  
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

  firewall { '100 allow 8009 access for RS tomcat':
    port   => 8009,
    proto  => tcp,
    action => accept,
  }

  package { $rspackages:
    ensure  => latest,
    require => [ Yumrepo['Abiquo-Rolling'], Package['redis'] ],
    notify  => Service['abiquo-tomcat']
  }

  file { '/opt/abiquo/config':
    ensure  => directory,
    owner   => 'root',
    mode    => '0755',
    require => Package[$rspackages]
  }

  if ! defined(Service['abiquo-tomcat']) {
    service { 'abiquo-tomcat':
      ensure  => running,
      enable  => true,
      require => [ Service['redis'], Concat['/opt/abiquo/config/abiquo.properties'] ]
    }
  }
  
  abiproperties::register { 'Server properties for RS':
    content => "[remote-services]\n",
    order   => '15',
  }

  # Minimum set of properties to define.
  if ! defined(Abiquo::Property['abiquo.rabbitmq.username']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.username', {'value' => 'guest', 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.password']) { ensure_resource('abiquo::property', "abiquo.rabbitmq.password", {'value' => "guest", 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.host']) { ensure_resource('abiquo::property', "abiquo.rabbitmq.host", { 'value' => "127.0.0.1", 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.port']) { ensure_resource('abiquo::property', "abiquo.rabbitmq.port", { 'value' => "5672", 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.redis.port']) { ensure_resource('abiquo::property', "abiquo.redis.port", { 'value' => "6379", 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.redis.host']) { ensure_resource('abiquo::property', "abiquo.redis.host", { 'value' => "localhost", 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.datacenter.id']) { ensure_resource('abiquo::property', "abiquo.datacenter.id", { 'value' => $::hostname, 'section' => 'remote-services' }) }
}