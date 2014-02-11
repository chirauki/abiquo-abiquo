class abiquo::api::update inherits abiquo::api {
  exec { 'Stop Abiquo tomcat before upgrade.':
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command => 'service abiquo-tomcat stop',
    unless  => 'ps -ef | grep java | grep /opt/abiquo/tomcat',
  }

  package { $apipkgs:
    ensure  => latest,
    require => [ Yumrepo['Abiquo-Base'], Exec['Stop Abiquo tomcat before upgrade.'] ],
    notify  => Service['abiquo-tomcat']
  }

  exec { 'Abiquo apply database delta':
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command => 'mysql kinton < `ls /usr/share/doc/abiquo-server/database/kinton-delta-*.sql`',
    unless  => 'test `mysql kinton -B --skip-column-names -e "select count(*) from DATABASECHANGELOG where MD5SUM in ($(grep Changeset /usr/share/doc/abiquo-server/database/kinton-delta-* | awk -F"Checksum: " \'{print $2}\' | cut -d\')\' -f1 | awk \'{print "\x27" $1 "\x27,"}\') \'\')"` -eq `grep Changeset /usr/share/doc/abiquo-server/database/kinton-delta-* | awk -F"Checksum: " \'{print $2}\' | cut -d\')\' -f1 | awk \'{print "\x27" $1 "\x27,"}\' | wc -l`',
    require => [ Package['abiquo-server'], Exec['Stop Abiquo tomcat before upgrade.'] ]
  }

  abiproperties::register { 'Server properties for API':
    content => template('abiquo/properties.server.erb'),
    order   => '02',
    require => [ Exec['Abiquo apply database delta'] ]
  }


  service { "abiquo-tomcat":
    ensure    => running,
    enable    => true,
    hasstatus => false,
    pattern   => "java.*/opt/abiquo/tomcat",
    require   => [ Package[$apipkgs], Exec['Abiquo apply database delta'], Concat['/opt/abiquo/config/abiquo.properties'] ]
  }
}