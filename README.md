# ArcGIS Enterprise Linux One Click Install Script
[中文说明](https://github.com/crazyxhz/ArcGIS-Enterprise-One-Click-Install/blob/master/README_CN.md)
##Overview
This auto install script supports the following ArcGIS Enterprise components' automatic installation and configuration (Linux version): ArcGIS Server, Portal for ArcGIS, ArcGIS DataStore. When the script completes its installation part. It will configure the installed products to its classic configuration: Federate ArcGIS Server with Portal for ArcGIS. Config ArcGIS DataStore with relational and tileCache Database.
 
##Introductions:
###File structure
```
rpm/		Linux dependency packages required by ArcGIS
yum163/		Redhat 6/7's netease yum repositories
init.sh		auto install script
config.sh	configuration file		
```

###**Notes on configuration file(important)**:

Before run the auto install script. You must modify the config.sh file to suit your own needs. This configuration file contains the information needed by the auto install script such as the license file, the ArcGIS Enterprise installation media ISO path, the account information. If not specified these info correctly, the auto install script will not function correctly.

```
newhostname="yourhostname"		
dnssuffix="yourdnssuffix"
arcgisuser='youraccout'
arcgisuserpwd='youraccoutpwd'
isofullpath='/path/to/arcgis.iso'
licensefullpath='/path/to/arcgis_ecp_license.ecp'
```
>newhostname

the target machine's new host name

>dnssuffix            

the target machine's dns suffix

>arcgisuser

account name: this account name serve as ArcGIS Server's OS account, Portal's OS account,  Server site's admin account, Portal's admin account

>arcgisuserpwd

The password to the previous account name

>isofullpath

ArcGIS Enterprise Linux installation ISO file's full path, or the cdrom path which is inserted with the Physical ArcGIS Enterprise Linux installation CD.

>licensefullpath

The license file's full path, which contains the portal and server's valid licenses.


###How to run the script
Copy all files in this repository to the target Linux machine, cd to the folder containing all the scripts and execute the following command:
```
bash init.sh
```
It will automatically install and config ArcGIS Enterprise on the machine. 
###Notes about quick install to the local machine's VM

 1. Share the folder containing this repository, Share path is something like \\local machine ip\oneclickinstall
 2. Share the folder containing the ArcGIS Enterprise ISO, Share path is something like \\local machine ip\iso
 3. in the vm, mout the shared folder using cifs using code below


```
(login as root)
cd ~
mkdir share iso
mount -t cifs //local machine ip/oneclickinstall -o username=your windows account,password=your windows account password ~/share
mount -t cifs //local machine ip/iso -o username=your windows account,password=your windows account password ~/iso
cd share
bash init.sh
```
If the target vm is RH 6 or 7 that did not support mount cifs in its factory setting. You can copy the matching script in yum 163 folder and run on the target machine. It will automatically install cifs support.


##System requirements:

**Supported ArcGIS Version**:Currently only support ArcGIS Enterprise Linux 10.5 (will consider add support of previous ArcGIS and its windows counterpart)


**Supported OS**:

 - Red Hat Enterprise Linux Server 6
 - Red Hat Enterprise Linux Server 7
 - SUSE Linux Enterprise Server 11
 - SUSE Linux Enterprise Server 12
 - Ubuntu Server LTS 16
 - CentOS Linux 6
 - CentOS Linux 7






