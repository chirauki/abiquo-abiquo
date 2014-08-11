class abiquo::jdk {
  package { "jdk":
    ensure  => latest,
    require => Yumrepo['Abiquo-Base']
  }

  file { '/usr/java/default/jre/lib/security/local_policy.jar':
    ensure  => present,
    source  => "puppet:///modules/${module_name}/jce/local_policy.jar",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['jdk']
  }

  file { '/usr/java/default/jre/lib/security/US_export_policy.jar':
    ensure  => present,
    source  => "puppet:///modules/${module_name}/jce/US_export_policy.jar",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['jdk']
  }
}