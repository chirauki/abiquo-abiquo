# == Class: abiquo
#
# This is the base class to provide Abiquo components.
# Components available are API, client and remote service
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { abiquo:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Marc Cirauqui <marc.cirauqui@abiquo.com>
#
# === Copyright
#
# Copyright 2014 Abiquo, unless otherwise noted.
#
class abiquo (
  $abiquo_version   = "3.2",
  $upgrade_packages = false,
  $gpgcheck         = true,
  $baserepo         = "",
  $rollingrepo      = ""
){
  yumrepo { "Abiquo-Base":
    name          => "abiquo-base",
    descr         => "abiquo-base-${abiquo_version}",
    baseurl       => $baserepo ? {
      ""        => "http://mirror.abiquo.com/abiquo/${abiquo_version}/os/x86_64/",
      default   => $baserepo
    },
    gpgcheck      => $gpgcheck ? {
      true  => 1,
      false => 0,
    },
    http_caching  => "none",
    notify        => Exec['yum-clean-metadata']
  }

  yumrepo { "Abiquo-Rolling":
    name          => "abiquo-rolling",
    descr         => "abiquo-rolling-${abiquo_version}",
    baseurl       => $rollingrepo ? {
      ""        => "http://mirror.abiquo.com/abiquo/${abiquo_version}/updates/x86_64/",
      default   => $rollingrepo
    },
    gpgcheck      => $gpgcheck ? {
      true  => 1,
      false => 0,
    },
    http_caching  => "none",
    require       => Yumrepo['Abiquo-Base'],
    notify        => Exec['yum-clean-metadata']
  }

  exec { 'yum-clean-metadata':
    path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command     => "yum clean all",
    refreshonly => true
  }

  class { 'selinux': 
    mode => 'disabled'
  }

  host { 'Add hostname to /etc/hosts':
    ensure  => present,
    name    => $::hostname,
    ip      => $::ipaddress,
  }

  # used by other modules to register themselves in the motd
  define abiproperties::register($content="", $order=10) {
    if $content == "" {
      $body = $name
    } else {
      $body = $content
    }

    concat::fragment{ "properties_fragment_$name":
      target  => '/opt/abiquo/config/abiquo.properties',
      order   => $order,
      content => "$body"
    }
  }

  define property($propname="", $value, $section) {
    if $propname == "" {
      $realname = $title
    } else {
      $realname = $propname
    }

    $offset = $section ? {
      'server'          => 10,
      'remote-services' => 20,
    }

    $sum = stringsum($realname)
    abiproperties::register { "property_$realname":
      content => "$realname = $value\n",
      order   => "$offset",
    }

    if $realname == "abiquo.appliancemanager.repositoryLocation" {
      file { "/opt/vm_repository":
        ensure => 'directory'
      }

      mount { "/opt/vm_repository":
        device  => "$value",
        fstype  => "nfs",
        ensure  => "mounted",
        options => "defaults",
        atboot  => true,
        require => File['/opt/vm_repository'],
      }
    }
  }
}
