class abiquo::api inherits abiquo {
  include abiquo::jdk
  include abiquo::redis
  include abiquo::rabbit
  include abiquo::mariadb

  $apipkgs = ["abiquo-api", "abiquo-server", "abiquo-core", "abiquo-m"]
}