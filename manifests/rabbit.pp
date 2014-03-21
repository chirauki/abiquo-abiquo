class abiquo::rabbit {
  package { "rabbitmq-server":
    ensure  => latest,
    require => Yumrepo["Abiquo-Base"]
  }

  service { "rabbitmq-server":
    enable  => true,
    ensure  => running,
    require => Package["rabbitmq-server"]
  }  
}