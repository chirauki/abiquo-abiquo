class abiquo::params {
  $abiquo_version = "2.9"
  $rollingrepourl = "http://mirror.abiquo.com/abiquo/2.9/os/x86_64/"
  #$baserepourl = "http://mirror.abiquo.com/abiquo/2.6/os/x86_64/"
  $baserepourl = $rollingrepourl
  $secure = false
  # For RS
  $apiaddress = "192.168.1.132"
  $rstype = "publiccloud"
}