class abiquo::jdk {
  package { "jdk":
    ensure  => latest,
    require => Yumrepo['Abiquo-Base']
  }

  $java_ver = "8"
  if versioncmp($abiquo::abiquo_version, "3.2") >=0 {
    $java_ver = "8"
  }
  else {
    $java_ver = "7"
  }

  file { '/usr/java/default/jre/lib/security/local_policy.jar':
    ensure  => present,
    source  => "puppet:///modules/${module_name}/jce/${java_ver}/local_policy.jar",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['jdk']
  }

  file { '/usr/java/default/jre/lib/security/US_export_policy.jar':
    ensure  => present,
    source  => "puppet:///modules/${module_name}/jce/${java_ver}/US_export_policy.jar",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['jdk']
  }
}