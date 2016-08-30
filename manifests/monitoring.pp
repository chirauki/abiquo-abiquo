class abiquo::monitoring (
  $kairosdb_port          = 8080,
  $kairosdb_version       = "0.9.4-6",
  $cassandra_cluster_name = "abiquo",
  $emmett_port            = 36638,
  $emmett_settings        = [ 
    "emmett.database.url"    = "jdbc:mysql://localhost:3306/watchtower",
    "emmett.kairosdb.host"   = "localhost",
    "amqp.rabbitmq.host"     = "localhost",
    "amqp.rabbitmq.username" = "abiquo",
    "amqp.rabbitmq.password" = "abiquo"
  ],
  $delorean_settings      = [
    "delorean.database.url"  = "jdbc:mysql://localhost:3306/watchtower",
    "delorean.kairosdb.host" = "localhost",
    "amqp.rabbitmq.host"     = "localhost",
    "amqp.rabbitmq.username" = "abiquo",
    "amqp.rabbitmq.password" = "abiquo"
  ]
) {
  include abiquo::firewall
  include abiquo::ntp
  
  class { 'abiquo::monitoring::cassandra':
    cassandra_cluster_name => $cassandra_cluster_name
  }
  
  class { 'abiquo::monitoring::kairosdb':
    kairosdb_port    => $kairosdb_port,
    kairosdb_version => $kairosdb_version
  }

  if versioncmp($abiquo::abiquo_version, '3.8') >= 0 {
    class { 'abiquo::monitoring::watchtower':
      emmett_port       => 36638,
      emmett_settings   => $emmett_settings,
      delorean_settings => $delorean_settings
    }
  }
}