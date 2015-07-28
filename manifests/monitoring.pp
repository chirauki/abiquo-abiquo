class abiquo::monitoring {
  include abiquo::firewall
  include abiquo::ntp
  include abiquo::monitoring::cassandra
  include abiquo::monitoring::kairosdb
}