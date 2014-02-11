class abiquo::remoteservice inherits abiquo {
  include abiquo::jdk
  include abiquo::redis
  
  if versioncmp($abiquo_version, "2.7") <= 0 {
    $rspackages = $rstype ? {
      publiccloud  => ["abiquo-vsm", "abiquo-virtualfactory", "abiquo-nodecollector" ],
      datacenter   => ["abiquo-vsm", "abiquo-virtualfactory", "abiquo-nodecollector", "abiquo-ssm", "abiquo-am"]
    }
  }
  else {
    $rspackages = $rstype ? {
      publiccloud => ["abiquo-vsm", "abiquo-virtualfactory", "abiquo-nodecollector", "abiquo-cpp"],
      datacenter  => ["abiquo-vsm", "abiquo-virtualfactory", "abiquo-nodecollector", "abiquo-ssm", "abiquo-am"]
    }
  }
}