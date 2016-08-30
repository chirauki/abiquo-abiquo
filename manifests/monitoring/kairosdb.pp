class abiquo::monitoring::kairosdb (
  $kairosdb_port          = 8080,
  $kairosdb_version       = "0.9.4-6",
) 
{
  firewall { '100 allow kairosdb http access':
    port   => $kairosdb_port,
    proto  => tcp,
    action => accept,
  }

  class { '::kairosdb':
    version => $kairosdb_version,
  }

  class { '::kairosdb::datastore::cassandra':
    hosts => [
      "$::ipaddress:9160"
    ],
  }
}
