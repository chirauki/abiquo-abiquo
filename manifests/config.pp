class abiquo::config {
  file { [ '/opt/abiquo', '/opt/abiquo/config' ]:
    ensure  => directory,
    owner   => 'root',
    mode    => '0755',
    before  =>  Yumrepo['Abiquo-Base']
  } 

  concat { '/opt/abiquo/config/abiquo.properties':
    owner   => 'root',
    mode    => '0755',
    notify  => Service['abiquo-tomcat'],
    require => File['/opt/abiquo/config']
  }

  abiproperties::register { 'properties header':
    content => template('abiquo/properties.header.erb'),
    order   => '01'
  }
}