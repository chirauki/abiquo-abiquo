#abiquo-abiquo

You can use this module to install [Abiquo](http://www.abiquo.com) components in a CentOS machine.

Abiquo components will be selected by assigning specific classes to a node's manifest.

Depends on:

 - [puppetlabs/apache](https://forge.puppetlabs.com/puppetlabs/apache)
 - [puppetlabs/concat](https://forge.puppetlabs.com/puppetlabs/concat)
 - [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
 - [puppetlabs/firewall](https://forge.puppetlabs.com/puppetlabs/firewall)
 - [spiette/selinux](https://forge.puppetlabs.com/spiette/selinux)
 - [thias/sysctl](https://forge.puppetlabs.com/thias/sysctl)

#Notice on JCE

Since version 3.1, Abiquo requires [Oracle's Java Cryptography Extensions](http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html) to enctypt stored credentials. Since we cannot redistribute them, you need to manually download them and put jar files in ```files/jce``` directory. 

Starting with 3.2, Abiquo requires Java 1.8.0, so you need to create different dictories for each Java version.

Resulting tree should look like:

```
abiquo
  |
  |-- files
  |     |-- jce
  |          |-- 7
  |          |   |-- local_policy.jar
  |          |   |-- US_export_policy.jar
  |          |
  |          |-- 8
  |              |-- local_policy.jar
  |              |-- US_export_policy.jar
  |-- lib
  ...
```

**Note:** Missing those files will result on failed puppet run even if you are installing Abiquo < 3.1.

#Available components

##Abiquo

This is the base class. Its only purpose is to be able to define a different Abiquo version to setup. It defaults to the last publicly available version of Abiquo.

```
class { 'abiquo':
  abiquo_version    => "3.4",
  upgrade_packages  => false,
  gpgcheck          => true,
  gpgkeys          = "http://mirror.abiquo.com/RPM-GPG-KEY-Abiquo
  http://mirror.abiquo.com/RPM-GPG-KEY-MariaDB
  http://mirror.abiquo.com/RPM-GPG-KEY-RabbitMQ
  http://mirror.abiquo.com/RPM-GPG-RSA-KEY-Abiquo",
  baserepo          => "http://myrepo/packages/",
  rollingrepo       => "http://myrepo/updates/"
}
```

####Parameters

- **abiquo_version** a string denoting a major version of Abiquo (ie. 2.4, 2.6, etc. Not 2.4.1, 2.4.2, etc.).
- **upgrade_packages** boolean determinig wether or not Abiquo packages will be updated or not.
- **gpgcheck** boolean determinig wether or not Abiquo yum repositories will validate GPG signatures on packages.
- **gpgkeys** YUM GPG keys to verify Abiquo packages signatures.
- **baserepo** a URL if you want to use a custom yum repo for base packages.
- **rollingrepo** a URL if you want to use a custom yum repo for development version of RPM packages.


##Abiquo API

The Abiquo API class includes the API itself and the M webapp for events and outbound API.

```
class { 'abiquo::api':
  secure          => true,
  proxy           => false,
  proxyhost       => '',
  install_db      => true,
  install_rabbit  => true,
  install_redis   => true,
  db_url          => '',
  db_user         => 'root',
  db_pass         => ''
}
```

####Parameters

- **secure determines** wether SSL will be set up or not.
- **proxy** determines if Abiquo will be acessed thorugh a reverse proxy. Sets a tomcat connector on port 8011 for that matter.
- **proxyhost** the reverse proxy FQDN which should be written in API reponses.
- **install_db** boolean that determines if the MariaDB or MySQL server will be installed.
- **install_rabbit** boolean that determines if the RabbitMQ server will be installed.
- **install_redis** boolean that determines if the Redis server will be installed.
- **db_url** If not using local database, specifies the IP and port of the MySQL server in the form ```IP:PORT```. If this parameter has a value, local database will not be installed.
- **db_user** The user used to connect to the MariaDB server.
- **db_pass** The password for the aforementioned user.

##Abiquo client

Client class installs the flex client app for 2.6 or the ui webapp for 2.8+

```
class { 'abiquo::client': 
  secure         = true,
  self_signed    = true,
  ssl_cert       = '/etc/pki/tls/certs/localhost.crt',
  ssl_key        = '/etc/pki/tls/private/localhost.key',
  ssl_certs_dir  = '',
  ui_custom      = {},
  api_address    = '',
  api_endpoint   = '',
  proxy_timeout  = 600,
  servername     = $::fqdn,
  am_proxy       = []
}
```

####Parameters

- **secure** determines wether SSL will be set up or not in Apache server hosting the UI webapp (2.8+).
- **self_signed** determines wether SSL will use a self signed certificate. If not, you should define the path to your cert.
- **ssl_cert** The path to your SSL certificate file.
- **ssl_key** The path to the private key file for your cert.
- **ssl_certs_dir** The path where the certificate files are located.
- **ui_custom** From Abiquo 3.4, this hash will be set as the custom client config file.
- **api_address** is the IP address set as Apache proxy destination for Abiquo 3.2 or earlier.
- **api_endpoint** is the IP address to set as ```config.endpoint``` in UI's config file for Abiquo 3.2 or earlier.
- **proxy_timeout** is the timeout value for Apache proxy directive for AM.
- **servername** The ```servername``` directive to be used in Apache vhost file.
- **am_proxy** Is an array of ```proxy_pass``` directives for the ```apache::vhost``` object, in case you need to add vHosts to serve Abiquo AM on a distributed installation. Example:

```puppet
class { 'abiquo::client': 
  ui_custom => {
    'config.endpoint' => "https://$::ipaddress_eth1/api"
  },
  am_proxy => [
    { 'path' => '/am-rs', 'url' => 'http://10.60.10.18:8009/am' },
    { 'path' => '/am-mono', 'url' => 'http://10.60.10.20:8009/am' },
  ]
} 
```


##Abiquo remote services

This class installs and configures all the remote services needed to run a datacenter or public cloud regin in Abiquo.

```
class { 'abiquo::remoteservice':
  rstype        => 'publiccloud',
  install_redis => true,
}
```

####Parameters

- **rstype** determines the type of RS that will be setup. It can be ```datacenter```, ```publiccloud``` or ```full``` (```full``` will install all webapps for both the ```datacenter``` and ```publiccloud``` options).
- **install_redis** boolean that determines if the Redis server will be installed.


##Abiquo V2V

As it is advisable to set up V2V services in a separate machine from the RS server, this class will install the V2V module in a standalone server.

```
class { 'abiquo::v2v': }
```

####Parameters

This class does not take parameters. You can also set any of its properties using the property resource.


##Abiquo KVM

Sets up the KVM cloud node.

```
class { 'abiquo::kvm': 
  redis_host     => '192.168.2.2',
  redis_port     => 6379,
  aim_port       => 8889,
  aim_repository => '/opt/vm_repository',
  aim_datastore  => '/var/lib/virt',
  autobackup     => false,
  autorestore    => false,
}
```

####Parameters

- **redis_host** Address of the Redis server where to report events (Pre 3.x).
- **redis_port** Port of the Redis server where to report events (Pre 3.x).
- **aim_port** TCP port to where the AIM server will be listening. Defaults to ```8889```.
- **aim_repository** Directory where the VM repository is mounted. Defaults to ```/opt/vm_repository```.
- **aim_datastore** Datastore directory. Defaults to ```/var/lib/virt```.
- **autobackup** boolean that determines if the undeployed VMs will be backed up. Defaults to ```false```.
- **autorestore** boolean that determines if the deployed VMs will be restored from backup. Defaults to ```false```.


##Monitoring

Installs Cassandra 2.0 and KairosDB to be used as metrics backend for Abiquo.

```
class { 'abiquo::monitoring': }
```

####Parameters

This class does not take parameters.


##Zookeeper

Installs the Zookeeper server used to synchronize distributed APIs.

```
class { 'abiquo::zookeeper': }
```

####Parameters

This class does not take parameters. You can also set any of its properties using the property resource.


##Abiquo properties

The base Abiquo class provides a custom type that allows to set the values for each property defined in [Abiquo wiki](http://wiki.abiquo.com/display/ABI32/Abiquo+Configuration+Properties)

To set a property, you must make sure it is defined before the class that will use it.

```
abiquo::property { "some.property":
  value => "somevalue"
}
```

**Note** Specifying the property ```abiquo.appliancemanager.repositoryLocation``` will automatically setup the mount of the repository. For more 


####Parameters

- **propname** is optional and defults to the resource title. It specifies the property name you want to set.
- **value** is the value of the property you want to set.

**Note** The ```section``` parameter has been removed in the latest release. The module will omit it if defined.

#Examples

##Monolithic install

```
class { 'abiquo': }
class { 'abiquo::api': }
class { 'abiquo::client': }
class { 'abiquo::remoteservice': }
class { 'abiquo::v2v': }
```

##Server only (API and GUI)

```
class { 'abiquo': }
class { 'abiquo::api': }
class { 'abiquo::client': }
```

##Remote services for Public cloud regions

You will probably need to set the Rabbit IP address in the RS properties file:

```
abiquo::property{ 'abiquo.rabbitmq.host': value => "IP_ADDRESS_OF_API_SERVER", section => "remote-services" }
class { 'abiquo': }
class { 'abiquo::remoteservice': }
```

##Remote services for in premises datacenter

Again, you will need to set some properties (Note, the module will not ensure the repository is mounted):

```
abiquo::property{ 'abiquo.appliancemanager.localRepositoryPath': value => "/opt/vm_repository/", section => "remote-services" }
abiquo::property{ 'abiquo.appliancemanager.repositoryLocation': value => "192.168.2.50:/opt/vm_repository", section => "remote-services" }
abiquo::property{ 'abiquo.rabbitmq.host': value => "IP_ADDRESS_OF_API_SERVER", section => "remote-services" }
class { 'abiquo': }
class { 'abiquo::remoteservice': rstype => 'datacenter' }
```
