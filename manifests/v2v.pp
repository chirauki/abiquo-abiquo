class abiquo::v2v {
  include abiquo::jdk
  include abiquo::firewall
  include abiquo::tomcat

  $ensure = $abiquo::upgrade_packages ? {
    true  => latest,
    false => present,
  }

  package { 'abiquo-v2v':
    ensure  => $ensure,
    require => Yumrepo['Abiquo-Rolling'],
    notify  => Service['abiquo-tomcat']
  }

  # Minimum set of properties to define.
  if ! defined(Abiquo::Property['abiquo.rabbitmq.username']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.username', {'value' => 'guest', 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.password']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.password', {'value' => 'guest', 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.host']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.host', { 'value' => '127.0.0.1', 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.port']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.port', { 'value' => '5672', 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.redis.port']) { ensure_resource('abiquo::property', 'abiquo.redis.port', { 'value' => '6379', 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.redis.host']) { ensure_resource('abiquo::property', 'abiquo.redis.host', { 'value' => 'localhost', 'section' => 'remote-services' }) }
  if ! defined(Abiquo::Property['abiquo.datacenter.id']) { ensure_resource('abiquo::property', 'abiquo.datacenter.id', { 'value' => $::hostname, 'section' => 'remote-services' }) }
}