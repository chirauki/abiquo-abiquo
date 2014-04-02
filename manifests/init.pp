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
  $abiquo_version = "3.0",
  $baserepo = "",
  $rollingrepo = ""
){
  include concat::setup
  include abiquo::firewall

  yumrepo { "Abiquo-Base":
    name          => "abiquo-base",
    descr         => "abiquo-base-${abiquo_version}",
    baseurl       => $baserepo ? {
      ""        => "http://mirror.abiquo.com/abiquo/${abiquo_version}/os/x86_64/",
      default   => $baserepo
    },
    gpgcheck      => 0,
    http_caching  => "none"
  }

  yumrepo { "Abiquo-Rolling":
    name          => "abiquo-rolling",
    descr         => "abiquo-rolling-${abiquo_version}",
    baseurl       => $rollingrepo ? {
      ""        => "http://mirror.abiquo.com/abiquo/${abiquo_version}/os/x86_64/",
      default   => $rollingrepo
    },
    gpgcheck      => 0,
    http_caching  => "none",
    require       => Yumrepo['Abiquo-Base']
  }

  class { 'selinux': 
    mode => 'disabled'
  }

  host { 'Add hostname to /etc/hosts':
    ensure  => present,
    name    => $::hostname,
    ip      => $::ipaddress,
  }

  concat { '/opt/abiquo/config/abiquo.properties':
    owner   => 'root',
    mode    => '0755',
    notify  => Service['abiquo-tomcat']
  }

  abiproperties::register { 'properties header':
    content => template('abiquo/properties.header.erb'),
    order   => '01'
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
