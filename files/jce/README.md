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