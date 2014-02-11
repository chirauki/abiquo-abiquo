class abiquo::client inherits abiquo {
  if versioncmp($abiquo_version, "2.7") <= 0 {
    $uipkg = 'abiquo-client-premium'
  }
  else {
    notify { "Abiquo version ${abiquo_version} does not use flex client. Selecting abiquo-ui instead.": }
    $uipkg = "abiquo-ui"
  }
}