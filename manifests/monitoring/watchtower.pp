class abiquo::monitoring::watchtower (
  $emmett_port            = 36638,
  $install_db             = true,
  $db_host                = 'localhost',
  $db_user                = 'root',
  $db_pass                = ''
  $emmett_settings        = [ 
    "emmett.kairosdb.host"   = "localhost",
    "amqp.rabbitmq.host"     = "localhost",
    "amqp.rabbitmq.username" = "abiquo",
    "amqp.rabbitmq.password" = "abiquo"
  ],
  $delorean_settings      = [
    "delorean.kairosdb.host" = "localhost",
    "amqp.rabbitmq.host"     = "localhost",
    "amqp.rabbitmq.username" = "abiquo",
    "amqp.rabbitmq.password" = "abiquo"
  ],

) {
  firewall { '100 allow emmett access':
    port   => $emmett_port,
    proto  => tcp,
    action => accept,
  }

  $ensure = $abiquo::upgrade_packages ? {
    true  => latest,
    false => present,
  }

  package { ['abiquo-emmett', 'abiquo-delorean']:
    ensure   => $ensure
  }

  if $install_db == true {
    include abiquo::mariadb
  }
  else {
    notify { 'Not installing Watchtower database. Ensure a proper DB URL is configured.': }
  }

  $mysql_params = $db_pass ? {
    ''        => "-H $db_url -u$db_user",
    default   => "-H $db_url -u$db_user -p$db_pass",
  }

  $lqb_params = $db_pass ? {
    ''        => "-H $db_url -u$db_user",
    default   => "-H $db_url -u$db_user -p$db_pass",
  }

  # Database, only localhost
  exec { 'Abiquo Watchtower database schema':
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command => "mysql $mysql_params < /usr/share/doc/abiquo-watchtower/database/src/watchtower-1.0.0.sql",
    unless  => "mysql $mysql_params -e \"show databases\" | grep watchtower",
    require => Package['abiquo-delorean']
    notify  => Exec['Abiquo Watchtower liquibase update']
  }

  exec { 'Abiquo Watchtower liquibase update':
    path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command     => "/usr/bin/abiquo-watchtower-liquibase $mysql_params update",
    onlyif      => "/usr/bin/which abiquo-watchtower-liquibase",
    require     => Package['abiquo-delorean'],
    refreshonly => true,
  }

  # Handle config files
  define abiquo::delorean::property ($prop = $val) {
    hocon_setting { "delorean_$prop":
      ensure  => present,
      path    => '/etc/abiquo/watchtower/abiquo-delorean.conf',
      setting => $prop,
      value   => $val,
      notify  => Service['abiquo-delorean']
    }
  }

  abiquo::delorean::property { $delorean_settings: }

  define abiquo::emmett::property ($prop = $val) {
    hocon_setting { "delorean_$prop":
      ensure  => present,
      path    => '/etc/abiquo/watchtower/abiquo-emmett.conf',
      setting => $prop,
      value   => $val,
      notify  => Service['abiquo-emmett']
    }
  }

  abiquo::emmett::property { $emmett_settings: }

  service { ['abiquo-emmett', 'abiquo-delorean']:
    ensure    => 'running',
    enable    => true,
    require   => Package['abiquo-emmett', 'abiquo-delorean']
  }
}
