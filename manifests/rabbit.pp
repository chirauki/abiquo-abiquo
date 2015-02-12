class abiquo::rabbit {
  package { 'rabbitmq-server':
    ensure  => latest,
    require => Yumrepo['Abiquo-Base']
  }

  service { 'rabbitmq-server':
    ensure  => running,
    enable  => true,
    require => Package['rabbitmq-server']
  }
}