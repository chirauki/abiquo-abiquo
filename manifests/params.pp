class abiquo::params {
  $abiquo_version = "2.6"
  $apilocation = versioncmp($abiquo_version, "2.7") ? {
    /-1|0/  => "http://${::ipaddress}/api",
    1       => "http://${::ipaddress}:8009/api"
  }
  $apiaddress = "192.168.1.138"
  $rstype = "publiccloud"
}