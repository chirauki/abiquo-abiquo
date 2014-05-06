class abiquo::remoteservice (
  $rstype         = "publiccloud"
) {
  include abiquo::jdk
  include abiquo::redis
  include abiquo::firewall
  include abiquo::tomcat
  
  if versioncmp($abiquo::abiquo_version, "2.7") <= 0 {
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