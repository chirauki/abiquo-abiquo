class { 'abiquo::kvm':
  redis_host     => '192.168.2.2',
  redis_port     => 6379,
  aim_port       => 8889,
  aim_repository => '/opt/vm_repository',
  aim_datastore  => '/var/lib/virt',
  autobackup     => false,
  autorestore    => false,
}
