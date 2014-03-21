class abiquo::jdk {
  package { "jdk":
    ensure  => latest,
    require => Yumrepo['Abiquo-Base']
  }
}