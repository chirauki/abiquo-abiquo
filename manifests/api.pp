class abiquo::api (
  $abiquo_version = "2.9",
  $secure         = true,
) {
  include abiquo::jdk
  include abiquo::redis
  include abiquo::rabbit
  include abiquo::mariadb
  
  class { 'abiquo': 
    abiquo_version => $abiquo_version
  }

  $apipkgs = ["abiquo-api", "abiquo-server", "abiquo-core", "abiquo-m"]

  exec { 'Stop Abiquo tomcat before upgrade.':
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command => 'service abiquo-tomcat stop',
    unless  => 'ps -ef | grep java | grep /opt/abiquo/tomcat',
  }

  package { $apipkgs:
    ensure  => latest,
    require => [ Yumrepo['Abiquo-Rolling'], Exec['Stop Abiquo tomcat before upgrade.'], Package['MariaDB-server', 'redis', 'jdk']] ,
    notify  => Service['abiquo-tomcat']
  }

  if $::kinton_present {
    exec { 'Abiquo apply database delta':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => 'mysql kinton < `ls /usr/share/doc/abiquo-server/database/kinton-delta-*.sql`',
      unless  => 'test `mysql kinton -B --skip-column-names -e "select count(*) from DATABASECHANGELOG where MD5SUM in ($(grep Changeset /usr/share/doc/abiquo-server/database/kinton-delta-* | awk -F"Checksum: " \'{print $2}\' | cut -d\')\' -f1 | awk \'{print "\x27" $1 "\x27,"}\') \'\')"` -eq `grep Changeset /usr/share/doc/abiquo-server/database/kinton-delta-* | awk -F"Checksum: " \'{print $2}\' | cut -d\')\' -f1 | awk \'{print "\x27" $1 "\x27,"}\' | wc -l`',
      require => [ Package['abiquo-server'], Exec['Stop Abiquo tomcat before upgrade.'] ]
    }
    $execdep = Exec['Abiquo apply database delta']
  }
  else {
    exec { 'Abiquo database schema':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => 'mysql < /usr/share/doc/abiquo-server/database/kinton-schema.sql',
      unless  => 'mysql -e "show databases" | grep kinton',
      require => Package['abiquo-server']
    }
    $execdep = Exec['Abiquo database schema']
  }

  firewall { '100 allow rabbit access':
    port   => 5672,
    proto  => tcp,
    action => accept,
  }

  service { "abiquo-tomcat":
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "java.*/opt/abiquo/tomcat",
    require   => [ Package[$apipkgs], $execdep, Concat['/opt/abiquo/config/abiquo.properties'] ]
  }

  abiproperties::register { 'Server properties for API':
    content => "[server]\n",
    order   => '05',
  }

  # Minimum set of properties to define.
  if ! defined(Abiquo::Property['abiquo.server.sessionTimeout']) { ensure_resource('abiquo::property', 'abiquo.server.sessionTimeout', {'value' => '60', 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.server.mail.server']) { ensure_resource('abiquo::property', "abiquo.server.mail.server", {'value' => "127.0.0.1", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.server.mail.user']) { ensure_resource('abiquo::property', "abiquo.server.mail.user", { 'value' => "none@none.es", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.server.mail.password']) { ensure_resource('abiquo::property', "abiquo.server.mail.password", { 'value' => "none", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.username']) { ensure_resource('abiquo::property', "abiquo.rabbitmq.username", { 'value' => "guest", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.password']) { ensure_resource('abiquo::property', "abiquo.rabbitmq.password", { 'value' => "guest", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.host']) { ensure_resource('abiquo::property', "abiquo.rabbitmq.host", { 'value' => "127.0.0.1", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.rabbitmq.port']) { ensure_resource('abiquo::property', "abiquo.rabbitmq.port", { 'value' => "5672", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.database.user']) { ensure_resource('abiquo::property', "abiquo.database.user", { 'value' => "root", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.database.password']) { ensure_resource('abiquo::property', "abiquo.database.password", { 'value' => "", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.database.host']) { ensure_resource('abiquo::property', "abiquo.database.host", { 'value' => "127.0.0.1", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.auth.module']) { ensure_resource('abiquo::property', "abiquo.auth.module", { 'value' => "abiquo", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.server.api.location']) { ensure_resource('abiquo::property', "abiquo.server.api.location", { 'value' => "http://localhost/api", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.m.identity']) { ensure_resource('abiquo::property', "abiquo.m.identity", { 'value' => "admin", 'section' => "server" }) }
  if ! defined(Abiquo::Property['abiquo.m.credential']) { ensure_resource('abiquo::property', "abiquo.m.credential", { 'value' => "xabiquo", 'section' => "server" }) }
}