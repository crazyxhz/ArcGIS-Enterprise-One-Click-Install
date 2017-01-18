#!/usr/bin/env bash

#导入GPG key
sudo rpm --import http://mirrors.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-7

#修改repo文件添加CentOS 7.X的YUM源
cd /etc/yum.repos.d/
cp rhel-source.repo rhel-source.repo.bak


cat > rhel-source.repo<<-EOF
[base]
[base]
name=CentOS-$releasever-Base
baseurl=http://centos.ustc.edu.cn/centos/7/os/x86_64/
gpgcheck=1
gpgkey=http://mirrors.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever-Updates
baseurl=http://centos.ustc.edu.cn/centos/7/os/x86_64/
gpgcheck=1
gpgkey=http://mirrors.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever-Extras
baseurl=http://centos.ustc.edu.cn/centos/7/os/x86_64/
gpgcheck=1
gpgkey=http://mirrors.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-7

[centosplus]
name=CentOS-$releasever-Plus
baseurl=http://centos.ustc.edu.cn/centos/7/os/x86_64/
gpgcheck=1
EOF


#清除缓存查看是否生效
yum clean all
yum makecache
yum repolist

#安装yum-plugin-downloadonly插件
yum install -y yum-plugin-downloadonly

#YUM只下载不安装
#yum install --downloadonly --downloaddir=/tmp/pacemaker pacemaker
yum install -y cifs-utils

