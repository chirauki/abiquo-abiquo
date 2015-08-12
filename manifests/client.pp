class abiquo::client (
  $secure         = true,
  $self_signed    = true,
  $ssl_cert       = '/etc/pki/tls/certs/localhost.crt',
  $ssl_key        = '/etc/pki/tls/private/localhost.key',
  $ssl_certs_dir  = '',
  $ui_custom      = {},
  $api_address    = '',
  $api_endpoint   = '',
  $proxy_timeout  = 600,
  $servername     = $::fqdn,
  $am_proxy       = []
) {
  include abiquo::ntp
  include abiquo::jdk
  include abiquo::firewall
  
  $f_api_address = $api_address ? {
    ''        => $::ipaddress,
    default   => $api_address,
  }

  $f_api_endpoint = $api_endpoint ? {
    ''        => $::ipaddress,
    default   => $api_endpoint,
  }

  if versioncmp($abiquo::abiquo_version, '2.8') >= 0 {
    $uipkg = 'abiquo-ui'
  }
  else {
    $uipkg = 'abiquo-client-premium'
    notify { "Abiquo version ${abiquo::abiquo_version} does not use HTML client. Selecting abiquo-client-premium instead.": }
  }

  $ensure = $abiquo::upgrade_packages ? {
    true  => latest,
    false => present,
  }

  if $uipkg == 'abiquo-ui' {
    package { 'abiquo-ui':
      ensure  => $ensure,
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

    $default_proxy_pass = [
      { 'path' => '/api', 'url' => "ajp://${f_api_address}:8010/api" },
      { 'path' => '/legal', 'url' => "ajp://${f_api_address}:8010/legal" },
      { 'path' => '/am', 'url' => "ajp://${f_api_address}:8010/am", 'params' => {'timeout' => $proxy_timeout} },
    ]
    
    if $secure == true {
      if $self_signed == true {
        file { '/etc/pki/abiquo':
          ensure => directory
        }

        openssl::certificate::x509 { $servername:
          ensure       => present,
          country      => 'ES',
          organization => 'Abiquo.com',
          commonname   => $servername,
          state        => 'Barcelona',
          locality     => 'Barcelona',
          unit         => 'Puppet Masters',
          email        => 'abipuppet@abiquo.com',
          days         => 3650,
          base_dir     => '/etc/pki/abiquo',
          owner        => 'root',
          group        => 'root',
          force        => false,
          require      => File['/etc/pki/abiquo']
        }

        # $vhost_defaults = {
        #   port          => '443',
        #   docroot       => '/var/www/html',
        #   ssl           => true,
        #   ssl_cert      => "/etc/pki/abiquo/$servername.crt",
        #   ssl_key       => "/etc/pki/abiquo/$servername.key",
        #   ssl_certs_dir => '/etc/pki/abiquo/',
        #   require       => Openssl::Certificate::X509[$servername]
        # }

        # unless empty($am_proxy) == true {
        #   create_resources(apache::vhost, $am_proxy, $vhost_defaults)
        # }

        $proxy_pass = concat($default_proxy_pass, $am_proxy)

        apache::vhost { 'abiquo-ssl':
          servername    => $servername,
          port          => '443',
          docroot       => '/var/www/html',
          ssl           => true,
          ssl_cert      => "/etc/pki/abiquo/$servername.crt",
          ssl_key       => "/etc/pki/abiquo/$servername.key",
          ssl_certs_dir => '/etc/pki/abiquo/',
          proxy_pass    => $proxy_pass,
          directories   => [ {
              path             => '/var/www/html/ui',
              'options'        => 'MultiViews FollowSymLinks',
              'allowoverride'  => 'None',
              'order'          => 'allow,deny',
              'allow'          => 'from all',
              'directoryindex' => 'index.html'
            } ],
          rewrites      => [ {
              rewrite_rule => ['^/$ /ui/ [R]']
            } ],
          require       => [ Package['abiquo-ui'], Openssl::Certificate::X509[$servername] ]
        }
      } else {
        # $vhost_defaults = {
        #   port          => '443',
        #   docroot       => '/var/www/html',
        #   ssl           => true,
        #   ssl_cert      => $ssl_cert,
        #   ssl_key       => $ssl_key,
        #   ssl_certs_dir => $ssl_certs_dir,
        # }

        # unless empty($am_proxy) == true {
        #   create_resources(apache::vhost, $am_proxy, $vhost_defaults)
        # }

        $proxy_pass = concat($default_proxy_pass, $am_proxy)

        apache::vhost { 'abiquo-ssl':
          servername    => $servername,
          port          => '443',
          docroot       => '/var/www/html',
          ssl           => true,
          ssl_cert      => $ssl_cert,
          ssl_key       => $ssl_key,
          ssl_certs_dir => $ssl_certs_dir,
          proxy_pass    => $proxy_pass,
          directories   => [ {
              path             => '/var/www/html/ui',
              'options'        => 'MultiViews FollowSymLinks',
              'allowoverride'  => 'None',
              'order'          => 'allow,deny',
              'allow'          => 'from all',
              'directoryindex' => 'index.html'
            } ],
          rewrites      => [ {
              rewrite_rule => ['^/$ /ui/ [R]']
            } ],
          require       => Package['abiquo-ui']
        }
      }

      apache::vhost { 'abiquo-redir':
        port     => '80',
        docroot  => '/var/www/html',
        ssl      => false,
        rewrites => [ {
            rewrite_rule => ['.* https://%{SERVER_NAME}%{REQUEST_URI} [L,R=301]']
          } ],
        require  => Package['abiquo-ui']
      }
    }
    else {
      apache::vhost { 'abiquo':
        port        => '80',
        docroot     => '/var/www/html',
        ssl         => false,
        proxy_pass  => $proxy_pass,
        directories => [ {
            path             => '/var/www/html/ui',
            'options'        => 'MultiViews FollowSymLinks',
            'allowoverride'  => 'None',
            'order'          => 'allow,deny',
            'allow'          => 'from all',
            'directoryindex' => 'index.html'
          } ],
        rewrites    => [ {
            rewrite_rule => ['^/$ /ui/ [R]']
          } ],
        require     => Package['abiquo-ui']
      }
    }

    exec { 'Remove old client-premium':
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => 'yum remove abiquo-client-premium',
      onlyif  => 'test -d /opt/abiquo/tomcat/client-premium'
    }

    if versioncmp($abiquo::abiquo_version, '3.4') >= 0 {
      # Set API location in client-config-custom.json
      file { '/var/www/html/ui/config/client-config-custom.json':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => hash2json($ui_custom),
        notify  => Service['httpd'],
        require => Package['abiquo-ui']
      }
    }
    else {
      # Set API location in client-config.json
      $secure_value = $secure ? {
        true  => "sed -i 's/\\\"config.endpoint\\\":.*,/\\\"config.endpoint\\\": \\\"https:\\/\\/${f_api_endpoint}\\/api\\\",/' /var/www/html/ui/config/client-config.json",
        false => "sed -i 's/\\\"config.endpoint\\\":.*,/\\\"config.endpoint\\\": \\\"http:\\/\\/${f_api_endpoint}\\/api\\\",/' /var/www/html/ui/config/client-config.json",
      }

      exec { 'Set API and protocol in UI config':
        path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
        command => $secure_value,
        unless  => "grep ${f_api_endpoint} /var/www/html/ui/config/client-config.json",
        require => Package['abiquo-ui']
      }
    }
  }
  else {
    package { 'client-premium':
      ensure  => $ensure,
      require => [ Yumrepo['Abiquo-Rolling'], Package['jdk'] ],
      notify  => Service['abiquo-tomcat']
    }
  }

  firewall { '100 allow http and https access':
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }
}