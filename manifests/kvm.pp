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

  $ensure = $abiquo::upgrade_packages ? {
    true  => latest,
    false => present,
  }

  package { $pkgs:
    ensure  => $ensure,
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

  firewall { '100 allow VNC access':
    port   => 5900-5999,
    proto  => tcp,
    action => accept,
  }

  firewall { '100 allow AIM access':
    port   => $aim_port,
    proto  => tcp,
    action => accept,
  }
}