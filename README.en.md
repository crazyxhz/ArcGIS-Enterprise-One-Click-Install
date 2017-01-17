# ArcGIS Enterprise Linux One Click Install Script
##Overview
This auto install script support the following ArcGIS Enterprise component's linux version: ArcGIS Server 10.5, Portal for ArcGIS 10.5, ArcGIS DataStore 10.5's automatic installation and configuration. When the script completes its installation. It will configure the installed product to its classic configuration: Server federated with Portal. DataStore configured relational and tileCache Database.
 
##Introductions:
###File structure
```
rpm/		ArcGIS's Dependency packages
yum163/		Redhat 6/7's yum repository
init.sh		auto install script
config.sh	configuration file		
```

###**Notes on configuration file(important)**

Before run the auto install script. You need to modify the config.sh file to suit your own needs. This configuration file contains the information need by the auto install script such as the license file, the ArcGIS Enterprise installation ISO, the account information. If not specified these info correctly, the auto install script will not install correctly.

```
newhostname="cen7"		
dnssuffix="vm"
arcgisuser='arcgis'
arcgisuserpwd='arcgis'
isofullpath='/path/to/arcgis.iso'
licensefullpath='/path/to/arcgis_ecp_license.ecp'
```
>newhostname

the target machine's new host name

>dnssuffix            

the target machine's dns suffix

>arcgisuser

account name, note: this account name serve as ArcGIS Server OS account, ArcGIS Portal OS account,  Server site admin account, Portal admin account

>arcgisuserpwd

The password to the previous account name

>isofullpath

ArcGIS Enterprise Linux installation ISO file's full path, or the cdrom path which inserted the Physical ArcGIS Enterprise Linux installation CD.

>licensefullpath

The lincense file's full path which contains the portal and server licneses.


###How to run the script
Copy all files in this repository to the target Linux machine, such as folder /root/oneclick, then cd to the path and execute the following command:
```
bash init.sh
```
It will automatically install and config ArcGIS Enterprise on the machine. 
###Note on quick install to the local machine's VM

 1. Share the folder containing the repository, Share path is something like \\local machine ip\oneclickinstall
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
If the target vm is RH 6.5 or 7 that did not support mount cifs as factory setting. You can copy the matching script in yum 163 folder and run on the target machine. This will automatically install cifs support.


##System requirements:

**Supported ArcGIS Version**:Currently only support ArcGIS Enterprise Linux 10.5 (will consider add support of previous versions and windows version)


**Supported OS**:

 - Red Hat Enterprise Linux Server 6
 - Red Hat Enterprise Linux Server 7
 - SUSE Linux Enterprise Server 12
 - SUSE Linux Enterprise Server 11
 - Ubuntu Server LTS 16
 - CentOS Linux 6
 - CentOS Linux 7






