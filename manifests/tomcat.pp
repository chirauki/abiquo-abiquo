class abiquo::tomcat {
  service { "abiquo-tomcat":
    ensure      => running,
    enable      => true,
    hasstatus   => false,
    pattern     => "java.*/opt/abiquo/tomcat",
    require     => Concat['/opt/abiquo/config/abiquo.properties']
  }
}