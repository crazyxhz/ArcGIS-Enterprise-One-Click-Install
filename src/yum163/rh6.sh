#!/usr/bin/env bash
rpm --import http://mirrors.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-6

#修改repo文件添加CentOS 6.X的YUM源
cd /etc/yum.repos.d/
cp rhel-source.repo rhel-source.repo.bak
cat > rhel-source.repo<<-EOF
[base]
name=CentOS-$releasever-Base
baseurl=http://centos.ustc.edu.cn/centos/6/os/x86_64/
gpgcheck=1
gpgkey=http://mirrors.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-6

[updates]
name=CentOS-$releasever-Updates
baseurl=http://centos.ustc.edu.cn/centos/6/os/x86_64/
gpgcheck=1
gpgkey=http://mirrors.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-6

[extras]
name=CentOS-$releasever-Extras
baseurl=http://centos.ustc.edu.cn/centos/6/os/x86_64/
gpgcheck=1
gpgkey=http://mirrors.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-6

[centosplus]
name=CentOS-$releasever-Plus
baseurl=http://centos.ustc.edu.cn/centos/6/os/x86_64/
gpgcheck=1
EOF



#清除缓存查看是否生效
yum clean all
yum makecache
yum repolist

#安装yum-plugin-downloadonly插件
yum install -y yum-plugin-downloadonly
yum install -y cifs-utils


#cp /etc/localtime /root/old.timezone
#rm /etc/localtime
#ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#
#date +%D -s 2016-12-31
#date +%T -s 17:57:00
