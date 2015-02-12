# used by other modules to register themselves in the motd
define abiquo::properties_register($order = 10, $content = '') {
  if $content == '' {
    $body = $name
  } else {
    $body = $content
  }

  concat::fragment{ "properties_fragment_${name}":
    target  => '/opt/abiquo/config/abiquo.properties',
    order   => $order,
    content => $body
  }
}