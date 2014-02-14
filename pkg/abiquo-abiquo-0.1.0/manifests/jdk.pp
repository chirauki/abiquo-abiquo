class abiquo::jdk inherits abiquo {
  package { "jdk":
    ensure  => latest,
    require => Yumrepo['Abiquo-Base']
  }
}