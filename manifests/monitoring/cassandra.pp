class abiquo::monitoring::cassandra (
  $cassandra_cluster_name = "abiquo"
) {
  include cassandra::datastax_repo
  include cassandra::java

  # Install Cassandra on the node.
  class { 'cassandra':
    authenticator   => 'PasswordAuthenticator',
    cluster_name    => $cassandra_cluster_name,
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => $::ipaddress,
    seeds           => $::ipaddress,
    service_systemd => true,
    require         => Class['cassandra::datastax_repo', 'cassandra::java'],
  }

  firewall { '100 allow cassandra access':
    port   => 9160,
    proto  => tcp,
    action => accept,
  }
}