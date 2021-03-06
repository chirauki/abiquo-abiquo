class abiquo::remoteservice (
  $rstype         = 'publiccloud',
  $install_redis  = true,
) {
  include abiquo::config
  include abiquo::jdk
  include abiquo::firewall
  include abiquo::tomcat
  
  if $install_redis == true { include abiquo::redis }

  if versioncmp($abiquo::abiquo_version, '2.7') <= 0 {
    $rspackages = $rstype ? {
      publiccloud => [ 'abiquo-vsm', 'abiquo-virtualfactory', 'abiquo-nodecollector' ],
      datacenter  => [ 'abiquo-vsm', 'abiquo-virtualfactory', 'abiquo-nodecollector', 'abiquo-ssm', 'abiquo-am', 'ipmitool' ],
      full        => [ 'abiquo-vsm', 'abiquo-virtualfactory', 'abiquo-nodecollector', 'abiquo-ssm', 'abiquo-am', 'ipmitool' ],
    }
  }
  else {
    $rspackages = $rstype ? {
      publiccloud => [ 'abiquo-vsm', 'abiquo-virtualfactory', 'abiquo-nodecollector', 'abiquo-cpp' ],
      datacenter  => [ 'abiquo-vsm', 'abiquo-virtualfactory', 'abiquo-nodecollector', 'abiquo-ssm', 'abiquo-am', 'ipmitool' ],
      full        => [ 'abiquo-vsm', 'abiquo-virtualfactory', 'abiquo-nodecollector', 'abiquo-cpp', 'abiquo-ssm', 'abiquo-am', 'ipmitool' ],
    }
  }

  $ensure = $abiquo::upgrade_packages ? {
    true  => latest,
    false => present,
  }

  package { $rspackages:
    ensure  => $ensure,
    require => Yumrepo['Abiquo-Rolling'],
    notify  => Service['abiquo-tomcat']
  }
  
  # Minimum set of properties to define.
  if ! defined(Abiquo::Property['abiquo.rabbitmq.username']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.username', {'value' => 'guest' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.password']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.password', {'value' => 'guest' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.host']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.host', { 'value' => '127.0.0.1' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.port']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.port', { 'value' => '5672' }) }
  if ! defined(Abiquo::Property['abiquo.redis.port']) { ensure_resource('abiquo::property', 'abiquo.redis.port', { 'value' => '6379' }) }
  if ! defined(Abiquo::Property['abiquo.redis.host']) { ensure_resource('abiquo::property', 'abiquo.redis.host', { 'value' => 'localhost' }) }
  if ! defined(Abiquo::Property['abiquo.datacenter.id']) { ensure_resource('abiquo::property', 'abiquo.datacenter.id', { 'value' => $::hostname }) }
}