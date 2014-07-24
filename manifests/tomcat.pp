class abiquo::tomcat {
  service { "abiquo-tomcat":
    ensure      => running,
    enable      => true,
    hasstatus   => false,
    pattern     => "java.*/opt/abiquo/tomcat",
    require     => Concat['/opt/abiquo/config/abiquo.properties']
  }

  file { '/opt/abiquo/tomcat/conf/server.xml':
    ensure    => present,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    content   => template('abiquo/server.xml.erb'),
    notify    => Service['abiquo-tomcat'],
    require   => Concat['/opt/abiquo/config/abiquo.properties']
  }
}