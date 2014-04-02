class abiquo::v2v {
  include abiquo::jdk
  include abiquo::firewall
  include abiquo::tomcat

  if ! defined(Firewall['100 allow 8009 access for RS tomcat']) {
    firewall { '100 allow 8009 access for RS tomcat':
      port   => 8009,
      proto  => tcp,
      action => accept,
    }
  }

  package { "abiquo-v2v":
    ensure  => latest,
    require => Yumrepo['Abiquo-Rolling'],
    notify  => Service['abiquo-tomcat']
  }

  if ! defined(File['/opt/abiquo/config']) {  
    file { '/opt/abiquo/config':
      ensure  => directory,
      owner   => 'root',
      mode    => '0755',
      require => Package['abiquo-v2v']
    }
  }

  if ! defined(Service['abiquo-tomcat']) {
    service { 'abiquo-tomcat':
      ensure  => running,
      enable  => true,
      require => Concat['/opt/abiquo/config/abiquo.properties']
    }
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