class abiquo::api (
  $secure         = true,
  $proxy          = false,
  $proxyhost      = '',
  $install_db     = true,
  $install_rabbit = true,
  $install_redis  = true,
  $db_url         = '',
  $db_user        = 'root',
  $db_pass        = ''
) {
  include abiquo::config
  include abiquo::firewall
  include abiquo::jdk
  include abiquo::tomcat

  if $install_redis == true { include abiquo::redis }
  if $install_rabbit == true { include abiquo::rabbit }
  
  if $db_url == '' {
    if $install_db == true {
      include abiquo::mariadb
    }
    else {
      notify { 'ERROR. Will not install DB and no db_url provided.': }
    }
  }
  else {
    exec { 'set db url':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      cwd     => '/opt/abiquo/tomcat/conf/Catalina/localhost/',
      command => "sed -i 's/mysql:\\/\\/.*\\/kinton/mysql:\\/\\/${db_url}\\/kinton/g' api.xml m.xml",
      unless  => "grep ${db_url} api.xml && grep ${db_url} m.xml",
      require => Package['abiquo-server'],
      notify  => Service['abiquo-tomcat']
    }

    exec { 'set db user':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      cwd     => '/opt/abiquo/tomcat/conf/Catalina/localhost/',
      command => "sed -i 's/username=\"\\([^\"]*\\)\"/username=\"${db_user}\"/g\' api.xml m.xml",
      unless  => "grep ${db_user} api.xml && grep ${db_user} m.xml",
      require => Package['abiquo-server'],
      notify  => Service['abiquo-tomcat']
    }

    exec { 'set db pass':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      cwd     => '/opt/abiquo/tomcat/conf/Catalina/localhost/',
      command => "sed -i 's/password=\"\\([^\"]*\\)\"/password=\"${db_pass}\"/g\' api.xml m.xml",
      unless  => "grep ${db_pass} api.xml && grep ${db_pass} m.xml",
      require => Package['abiquo-server'],
      notify  => Service['abiquo-tomcat']
    }

    abiquo::property { 'abiquo.database.user': value => $db_user, section => 'server' }
    abiquo::property { 'abiquo.database.password': value => $db_pass, section => 'server' }
    abiquo::property { 'abiquo.database.host': value => $db_url, section => 'server' }
  }
  
  $apipkgs = [ 'abiquo-api', 'abiquo-server', 'abiquo-core', 'abiquo-m' ]

  exec { 'Stop Abiquo tomcat before upgrade.':
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command => 'service abiquo-tomcat stop',
    unless  => 'ps -ef | grep java | grep /opt/abiquo/tomcat',
  }

  if $::kinton_present == 1 {
    #notify { "Abiquo liquibase update present. Running.": }
    exec { 'Abiquo liquibase update':
      path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command     => '/usr/bin/abiquo-liquibase-update',
      onlyif      => '/usr/bin/which abiquo-liquibase-update',
      require     => [ Package['abiquo-server'], Exec['Stop Abiquo tomcat before upgrade.'] ],
      refreshonly => true,
    }

    #notify { "Applying Abiquo delta.": }
    exec { 'Abiquo apply database delta':
      path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command     => 'mysql kinton < `ls /usr/share/doc/abiquo-server/database/kinton-delta-*.sql`',
      unless      => 'test `mysql kinton -B --skip-column-names -e "select count(*) from DATABASECHANGELOG where MD5SUM in ($(grep Changeset /usr/share/doc/abiquo-server/database/kinton-delta-* | awk -F"Checksum: " \'{print $2}\' | cut -d\')\' -f1 | awk \'{print "\x27" $1 "\x27,"}\') \'\')"` -eq `grep Changeset /usr/share/doc/abiquo-server/database/kinton-delta-* | awk -F"Checksum: " \'{print $2}\' | cut -d\')\' -f1 | awk \'{print "\x27" $1 "\x27,"}\' | wc -l`',
      require     => [ Package['abiquo-server'], Exec['Stop Abiquo tomcat before upgrade.'] ],
      refreshonly => true,
    }

    $pkgnotify = [ Service['abiquo-tomcat'], Exec['Abiquo liquibase update', 'Abiquo apply database delta'] ]
  }
  else {
    exec { 'Abiquo database schema':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => 'mysql < /usr/share/doc/abiquo-server/database/kinton-schema.sql',
      unless  => 'mysql -e "show databases" | grep kinton',
      require => Package['abiquo-server']
    }

    $pkgnotify = [ Service['abiquo-tomcat'], Exec['Abiquo database schema'] ]
  }

  $ensure = $abiquo::upgrade_packages ? {
    true  => latest,
    false => present,
  }

  package { $apipkgs:
    ensure  => $ensure,
    require => [ Yumrepo['Abiquo-Rolling'], Exec['Stop Abiquo tomcat before upgrade.'], Package['jdk'] ] ,
    notify  => $pkgnotify,
  }

  firewall { '100 allow rabbit access':
    port   => 5672,
    proto  => tcp,
    action => accept,
  }

  if $proxy {
    firewall { '100 allow proxy connector access':
      port   => 8011,
      proto  => tcp,
      action => accept,
    }
  }

  abiquo::properties_register { 'Server properties for API':
    content => '[server]\n',
    order   => '05',
  }

  # Minimum set of properties to define.
  if ! defined(Abiquo::Property['abiquo.server.sessionTimeout']) { ensure_resource('abiquo::property', 'abiquo.server.sessionTimeout', {'value' => '60', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.server.mail.server']) { ensure_resource('abiquo::property', 'abiquo.server.mail.server', {'value' => '127.0.0.1', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.server.mail.user']) { ensure_resource('abiquo::property', 'abiquo.server.mail.user', { 'value' => 'none@none.es', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.server.mail.password']) { ensure_resource('abiquo::property', 'abiquo.server.mail.password', { 'value' => 'none', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.username']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.username', { 'value' => 'guest', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.password']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.password', { 'value' => 'guest', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.host']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.host', { 'value' => '127.0.0.1', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.port']) { ensure_resource('abiquo::property', 'abiquo.rabbitmq.port', { 'value' => '5672', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.database.user']) { ensure_resource('abiquo::property', 'abiquo.database.user', { 'value' => 'root', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.database.password']) { ensure_resource('abiquo::property', 'abiquo.database.password', { 'value' => '', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.database.host']) { ensure_resource('abiquo::property', 'abiquo.database.host', { 'value' => '127.0.0.1', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.auth.module']) { ensure_resource('abiquo::property', 'abiquo.auth.module', { 'value' => 'abiquo', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.server.api.location']) { ensure_resource('abiquo::property', 'abiquo.server.api.location', { 'value' => 'http://localhost:8009/api', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.m.identity']) { ensure_resource('abiquo::property', 'abiquo.m.identity', { 'value' => 'admin', 'section' => 'server' }) }
  if ! defined(Abiquo::Property['abiquo.m.credential']) { ensure_resource('abiquo::property', 'abiquo.m.credential', { 'value' => 'xabiquo', 'section' => 'server' }) }
}