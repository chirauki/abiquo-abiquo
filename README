#abiquo-abiquo

You can use this module to install Abiquo components in a CentOS machine.

Abiquo components will be selected by assigning specific classes to a node's manifest.

Depends on:

 - [puppetlabs/apache](https://forge.puppetlabs.com/puppetlabs/apache)
 - [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
 - [puppetlabs/firewall](https://forge.puppetlabs.com/puppetlabs/firewall)
 - [spiette/selinux](https://forge.puppetlabs.com/spiette/selinux)

##Abiquo API

The Abiquo API class includes the API itself and the M webapp for events and outbound API.

```
class { 'abiquo::api':
  abiquo_version => '2.9',
  secure         => true
}
```

####Parameters

- **abiquo_version** will be used to determine the mirror to download RPM's from.
- **secure determines** wether SSL will be set up or not.


##Abiquo client

Client class installs the flex client app for 2.6 or the ui webapp for 2.8+

```
class { 'abiquo::client': 
  abiquo_version => '2.9',
  secure         => true,
  api_address    => $::ipaddress
}
```

####Parameters

- **abiquo_version** will be used to determine the mirror to download RPM's from.
- **secure determines** wether SSL will be set up or not in Apache server hosting the UI webapp (2.8+).
- **api_address** is the IP address to set as ```config.endpoint``` in UI's config file (2.8+).

##Abiquo remote services

This class installs and configures all the remote services needed to run a datacenter or public cloud regin in Abiquo.

```
class { 'abiquo::remoteservice':
  abiquo_version => '2.9',
  rstype         => 'publiccloud'
}
```

####Parameters

- **abiquo_version** will be used to determine the mirror to download RPM's from.
- **rstype** determines the type of RS that will be setup. It can be ```datacenter``` or ```publiccloud```.

##Abiquo properties

The base Abiquo class provides a custom type that allows to set the values for each property defined in [Abiquo wiki](http://wiki.abiquo.com/display/ABI30/Abiquo+Configuration+Properties)

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

