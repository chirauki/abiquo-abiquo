#abiquo-abiquo

You can use this module to install Abiquo components in a CentOS machine.

Abiquo components will be selected by assigning specific classes to a node's manifest.

Depends on:

 - [puppetlabs/apache](https://forge.puppetlabs.com/puppetlabs/apache)
 - [puppetlabs/concat](https://forge.puppetlabs.com/puppetlabs/concat)
 - [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
 - [puppetlabs/firewall](https://forge.puppetlabs.com/puppetlabs/firewall)
 - [spiette/selinux](https://forge.puppetlabs.com/spiette/selinux)

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
  abiquo_version => "3.1",
  baserepo = "http://myrepo/packages/",
  rollingrepo = "http://myrepo/updates/"
}
```

####Parameters

- **abiquo_version** a string denoting a major version of Abiquo (ie. 2.4, 2.6, etc. Not 2.4.1, 2.4.2, etc.).
- **baserepo** a URL if you want to use a custom yum repo for base packages.
- **rollingrepo** a URL if you want to use a custom yum repo for development version of RPM packages.


##Abiquo API

The Abiquo API class includes the API itself and the M webapp for events and outbound API.

```
class { 'abiquo::api':
  secure     => true,
  $proxy     => false,
  $proxyhost => ''
}
```

####Parameters

- **secure determines** wether SSL will be set up or not.
- **proxy** determines if Abiquo will be acessed thorugh a reverse proxy. Sets a tomcat connector on port 8011 for that matter.
- **proxyhost** the reverse proxy FQDN which should be written in API reponses.

##Abiquo client

Client class installs the flex client app for 2.6 or the ui webapp for 2.8+

```
class { 'abiquo::client': 
  secure         => true,
  api_address    => $::ipaddress
}
```

####Parameters

- **secure determines** wether SSL will be set up or not in Apache server hosting the UI webapp (2.8+).
- **api_address** is the IP address to set as ```config.endpoint``` in UI's config file (2.8+).


##Abiquo remote services

This class installs and configures all the remote services needed to run a datacenter or public cloud regin in Abiquo.

```
class { 'abiquo::remoteservice':
  rstype  => 'publiccloud'
}
```

####Parameters

- **rstype** determines the type of RS that will be setup. It can be ```datacenter``` or ```publiccloud```.


##Abiquo V2V

As it is advisable to set up V2V services in a separate machine from the RS server, this class will install the V2V module in a standalone server.

```
class { 'abiquo::v2v': }
```

####Parameters

This class does not take parameters. You can also set any of its properties using the property resource.


##Abiquo properties

The base Abiquo class provides a custom type that allows to set the values for each property defined in [Abiquo wiki](http://wiki.abiquo.com/display/ABI31/Abiquo+Configuration+Properties)

To set a property, you must make sure it is defined before the class that will use it.

```
abiquo::property { "some.property":
  value => "somevalue",
  section => "server"
}
```

####Parameters

- **propname** is optional and defults to the resource title. It specifies the property name you want to set.
- **value** is the value of the property you want to set.
- **section** is the section in the properties file where the property should be. It can be either ```server``` or ```remote-services```


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
