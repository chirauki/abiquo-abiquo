class abiquo::client (
  $secure         = true,
  $api_address    = '',
  $api_endpoint   = '',
) {
  include abiquo::jdk

  $f_api_address = $api_address ? {
    ''        => $::ipaddress,
    default   => $api_address,
  }

  $f_api_endpoint = $api_endpoint ? {
    ''        => $::ipaddress,
    default   => $api_endpoint,
  }

  if versioncmp($abiquo::abiquo_version, "2.8") >= 0 {
    $uipkg = "abiquo-ui"
  }
  else {
    $uipkg = 'abiquo-client-premium'
    notify { "Abiquo version ${abiquo::abiquo_version} does not use HTML client. Selecting abiquo-client-premium instead.": }
  }

  if $uipkg == "abiquo-ui" {
    package { 'abiquo-ui':
      ensure  => $abiquo::upgrade_packages ? {
      true  => latest,
      false => present,
    },
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

    if $secure == true {
      $proxy_pass = [
        { 'path' => '/api', 'url' => "ajp://${f_api_address}:8010/api" },
        { 'path' => '/legal', 'url' => "ajp://${f_api_address}:8010/legal" },
        { 'path' => '/am', 'url' => "ajp://${f_api_address}:8010/am" },
      ]
    }
    else {
      $proxy_pass = [
        { 'path' => '/api', 'url' => "ajp://${f_api_address}:8010/api" },
        { 'path' => '/legal', 'url' => "ajp://${f_api_address}:8010/legal" },
      ]
    }

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
        true  => "sed -i 's/\\\"config.endpoint\\\":.*,/\\\"config.endpoint\\\": \\\"https:\\/\\/${f_api_endpoint}\\/api\\\",/' /var/www/html/ui/config/client-config.json",
        false => "sed -i 's/\\\"config.endpoint\\\":.*,/\\\"config.endpoint\\\": \\\"http:\\/\\/${f_api_endpoint}\\/api\\\",/' /var/www/html/ui/config/client-config.json",
      },
      unless  => "grep ${f_api_endpoint} /var/www/html/ui/config/client-config.json",
      require => Package['abiquo-ui']
    }
  }
  else {
    package { 'client-premium':
      ensure  => $abiquo::upgrade_packages ? {
        true  => latest,
        false => present,
      },
      require => [ Yumrepo['Abiquo-Rolling'], Package['jdk'] ],
      notify  => Service['abiquo-tomcat']
    }
  }
}