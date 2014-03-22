class abiquo::client (
  $abiquo_version = "2.9",
  $secure         = true,
  $api_address    = $::ec2_public_ipv4 ? {
                      undef     => $::ipaddress,
                      default   => $::ec2_public_ipv4
                    }
) {
  include abiquo::jdk
  
  if ! defined(Class['abiquo']) {
    class { 'abiquo': 
      abiquo_version => $abiquo_version
    }
  }

  if versioncmp($abiquo_version, "2.7") <= 0 {
    $uipkg = 'abiquo-client-premium'
  }
  else {
    notify { "Abiquo version ${abiquo_version} does not use flex client. Selecting abiquo-ui instead.": }
    $uipkg = "abiquo-ui"
  }

  if $uipkg == "abiquo-ui" {
    package { 'abiquo-ui':
      ensure  => latest,
      require => [ Yumrepo['Abiquo-Rolling'], Package['jdk'] ],
      notify  => Service['abiquo-tomcat'],
    }

    class { 'apache':
      default_mods        => false,
      default_vhost       => false,
      default_confd_files => false,
    }

    class { 'apache::mod::dir': }
    class { 'apache::mod::rewrite': }
    class { 'apache::mod::proxy': }
    class { 'apache::mod::proxy_ajp': }

    $proxy_pass = [
      { 'path' => '/api', 'url' => 'ajp://localhost:8010/api' },
      { 'path' => '/legal', 'url' => 'ajp://localhost:8010/legal' },
    ]

    if $secure == true {
      apache::vhost { 'abiquo-ssl':
        port            => '443',
        docroot         => '/var/www/html',
        ssl             => true,
        proxy_pass      => $proxy_pass,
        directories     => [ { path => '/var/www/html/ui', 'options' => 'MultiViews', 'allowoverride' => 'None', 'order' => 'allow,deny', 'allow' => 'from all', 'directoryindex' => 'index.html' } ],
        rewrites        => [ { rewrite_rule => ['^/$ /ui/ [R]'] } ],
        require         => Package['abiquo-ui']
      }

      apache::vhost { 'abiquo-redir':
        port            => '80',
        docroot         => '/var/www/html',
        ssl             => false,
        rewrites        => [ { rewrite_rule => ['.* https://%{SERVER_NAME}%{REQUEST_URI} [L,R=301]'] } ],
        require         => Package['abiquo-ui']
      }
    }
    else {
      apache::vhost { 'abiquo':
        port            => '80',
        docroot         => '/var/www/html',
        ssl             => false,
        proxy_pass      => $proxy_pass,
        directories     => [ { path => '/var/www/html/ui', 'options' => 'MultiViews', 'allowoverride' => 'None', 'order' => 'allow,deny', 'allow' => 'from all', 'directoryindex' => 'index.html' } ],
        rewrites        => [ { rewrite_rule => ['^/$ /ui/ [R]'] } ],
        require         => Package['abiquo-ui']
      }
    }
 
    exec { 'Remove old client-premium':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => "yum remove abiquo-client-premium",
      onlyif  => "test -d /opt/abiquo/tomcat/client-premium"
    }

    exec { 'Set API and protocol in UI config':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => $secure ? {
        true  => "sed -i 's/\\\"config.endpoint\\\":.*,/\\\"config.endpoint\\\": \\\"https:\\/\\/${api_address}\\/api\\\",/' /var/www/html/ui/config/client-config.json",
        false => "sed -i 's/\\\"config.endpoint\\\":.*,/\\\"config.endpoint\\\": \\\"http:\\/\\/${api_address}\\/api\\\",/' /var/www/html/ui/config/client-config.json",
      },
      require => Package['abiquo-ui']
    }
  }
  else {
    package { 'client-premium':
      ensure  => latest,
      require => [ Yumrepo['Abiquo-Rolling'], Package['jdk'] ],
      notify  => Service['abiquo-tomcat']
    }
  }
}