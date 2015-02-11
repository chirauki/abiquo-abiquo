class { 'abiquo::remoteservice':
  rstype        => 'publiccloud',
  install_redis => true,
}