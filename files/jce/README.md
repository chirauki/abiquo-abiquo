#3.1 Notice on JCE

Since version 3.1, Abiquo uses [Oracle's Java Cryptography Extensions](http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html) to enctypt stored credentials. Since we cannot redistribute them, you need to manually download them and put jar files in ```files/jce``` directory. Resulting tree should look like:

```
abiquo
  |
  |-- files
  |     |-- jce
  |          |-- local_policy.jar
  |          |-- US_export_policy.jar
  |-- lib
  ...
```

Missing those files will result on failed puppet run even if you are installing Abiquo < 3.1.