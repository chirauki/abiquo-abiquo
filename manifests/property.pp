define abiquo::property($value, $section, $propname='') {
  if $propname == '' {
    $realname = $title
  } else {
    $realname = $propname
  }

  $offset = $section ? {
    'server'          => 10,
    'remote-services' => 20,
  }

  $sum = stringsum($realname)
  abiquo::properties_register { "property_${realname}":
    content => "${realname} = ${value}\n",
    order   => $offset,
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