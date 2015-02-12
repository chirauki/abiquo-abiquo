class abiquo::kvm (
  $redis_host     = '',
  $redis_port     = 0,
  $aim_port       = 8889,
  $aim_repository = '/opt/vm_repository',
  $aim_datastore  = '/var/lib/virt',
  $autobackup     = false,
  $autorestore    = false,
){
  include abiquo::ntp
  
  $pkgs = [ 'abiquo-aim', 'libvirt', 'qemu-kvm' ]

  package { $pkgs:
    ensure  => installed,
    require => Yumrepo['abiquo-base']
  }

  file { '/etc/abiquo-aim.ini':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('abiquo/abiquo-aim.ini.erb'),
    notify  => Service['abiquo-aim'],
    require => Package['abiquo-aim']
  }

  service { 'abiquo-aim':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => '/usr/sbin/abiquo-aim',
    require   => Package['abiquo-aim']
  }
}