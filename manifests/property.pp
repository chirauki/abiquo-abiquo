define abiquo::property($value, $propname='') {
  if $propname == '' {
    $realname = $title
  } else {
    $realname = $propname
  }

  $sum = stringsum($realname)
  abiquo::properties_register { "property_${realname}":
    content => "${realname} = ${value}\n",
    order   => $sum,
  }

  if $realname == 'abiquo.appliancemanager.repositoryLocation' {
    file { '/opt/vm_repository':
      ensure => 'directory'
    }

    mount { '/opt/vm_repository':
      ensure  => 'mounted',
      device  => $value,
      fstype  => 'nfs',
      options => 'defaults',
      atboot  => true,
      require => File['/opt/vm_repository'],
    }
  }
}