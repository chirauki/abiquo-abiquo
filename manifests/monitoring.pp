class abiquo::monitoring {
  include abiquo::ntp
  include abiquo::monitoring::cassandra
  include abiquo::monitoring::kairosdb
}