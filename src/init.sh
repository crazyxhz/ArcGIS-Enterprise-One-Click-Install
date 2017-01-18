#!/usr/bin/env bash


if [[ $EUID -ne 0 ]]; then
        echo "该脚本必须以root运行!" 1>&2
        exit 1
fi
# 读取配置信息
source config.sh
source script/check_missing_packages.sh

if [ ! -f ${licensefullpath} ]; then
    echo ""
    echo "==========================许可路径无效，无法安装！=========================="
    echo ""
    exit 1
fi

#yes | cp -rf /etc/localtime /root/old.timezone
#rm /etc/localtime
ln -s -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#date +%D -s 2017-1-15 > /dev/null 2>&1
#date +%T -s 12:58:00 > /dev/null 2>&1


echo ""
echo "*********************************************************************************************"
echo "**|---------------------------------------------------------------------------------------|**"
echo "**|                               进行安装前系统设置                                      |**"
echo "**|---------------------------------------------------------------------------------------|**"
echo "*********************************************************************************************"
echo ""



echo "==================================当前操作系统信息==========================================="
echo "                              "OS_ID $OS_ID
echo "                              "OS_ID_Lower $OS_ID_Lower
echo "                              "OS_Release $OS_Release
echo "                              "OS_Release_Major $OS_Release_Major
echo "                              "OS_Release_Minor $OS_Release_Minor
echo "---------------------------------------------------------------------------------------------"

python script/preinstall.py ${newhostname} ${dnssuffix} ${arcgisuser} ${arcgisuserpwd} ${OS_Release_Major}

echo ""
echo "=======================================加载安装光盘=========================================="
echo ""
if [ ! -d /mnt/arcgiscd ]; then
    mkdir -p /mnt/arcgiscd
fi

if [[ ${isofullpath} == /dev/cd* ]];then
    mount -t iso9660 ${isofullpath} /mnt/arcgiscd
elif [[ ${isofullpath} == *.iso ]];then
    mount -o loop ${isofullpath} /mnt/arcgiscd
else
    echo ""
    echo "==============================只支持以光驱或者iso文件方式加载================================"
    echo ""
    exit 1
fi

echo ""
echo "=====================================安装光盘加载完毕========================================"
echo ""

filename=$(basename "$licensefullpath")
if [ ! -f /home/${arcgisuser}/${filename} ]; then
    yes | cp -rf ${licensefullpath} /home/${arcgisuser}
fi

echo ""
echo "========================================安装依赖包==========================================="
if [[ ${OS_ID_Lower} == "redhatenterpriseserver" ]] && [[  ${OS_Release_Major} == '6' ]] && [[ ${has_missing} = "true" ]]; then
    rpm -i rpm/rh6/*.rpm
elif [[ ${OS_ID_Lower} == "redhatenterpriseserver" ]] && [[  ${OS_Release_Major} == '7' ]] && [[ ${has_missing} = "true" ]]; then
    rpm -i rpm/rh7/*.rpm
elif [[ ${OS_ID_Lower} == "ubuntu" ]] && [[  ${OS_Release_Major} == '16' ]] && [[ ${has_missing} = "true" ]]; then
     dpkg -i rpm/ubuntu/*.deb
fi

echo ""
echo "=======================================依赖包安装完毕========================================"
echo ""


if [[  ${OS_ID_Lower} != "ubuntu" ]]; then
sudo -u ${arcgisuser} bash <<EOF
echo ""
echo "====================================${arcgisuser}用户打开文件限制==================================="
echo ""
echo "Hard limits:"
ulimit -Hn -Hu
echo "Soft limits:"
ulimit -Sn -Su
echo ""
echo ""
echo "*********************************************************************************************"
echo "**|---------------------------------------------------------------------------------------|**"
echo "**|                               进行ArcGIS安装                                          |**"
echo "**|---------------------------------------------------------------------------------------|**"
echo "*********************************************************************************************"
echo ""
echo ""



# Server 安装
if [ ! -d ~/unpacked/server ]; then
    mkdir -p ~/unpacked/server
    echo ""
    echo "=================================开始解压Server安装介质======================================"
    echo ""
    tar zxf /mnt/arcgiscd/ArcGIS_Server_Linux_105_154052.tar.gz -C ~/unpacked/server
    echo ""
    echo "=============================开始安装ArcGIS Server(静默安装)================================="
    echo ""
    cd ~/unpacked/server/ArcGISServer
    bash Setup -m silent -l yes -a /home/${arcgisuser}/${filename} -d /home/${arcgisuser}/arcgis/server
    echo ""
    echo "===================================ArcGIS Server 安装完毕===================================="
    echo ""
fi

# Portal 安装
if [ ! -d ~/unpacked/portal ]; then
    mkdir -p ~/unpacked/portal
    echo ""
    echo "==================================开始解压Portal安装介质====================================="
    echo ""
    tar zxf /mnt/arcgiscd/Portal_for_ArcGIS_Linux_105_154053.tar.gz -C ~/unpacked/portal
    echo ""
    echo "=================================开始安装Portal(静默安装)===================================="
    echo ""
    cd ~/unpacked/portal/PortalForArcGIS
    bash Setup -m silent -l yes -a /home/${arcgisuser}/${filename}
    echo ""
    echo "======================================Portal 安装完毕========================================"
    echo ""
fi

# DataStore 安装
if [ ! -d ~/unpacked/datastore ]; then
    mkdir -p ~/unpacked/datastore
    echo ""
    echo "===============================开始解压DataStore安装介质====================================="
    echo ""
    tar zxf /mnt/arcgiscd/ArcGIS_DataStore_Linux_105_154054.tar.gz -C ~/unpacked/datastore
    echo ""
    echo "===========================解压完毕，开始安装DataStore(静默安装)============================="
    echo ""
    cd ~/unpacked/datastore/ArcGISDataStore_Linux
    bash Setup -m silent -l yes
    echo ""
    echo "===================================DataStore 安装完毕========================================"
    echo ""
fi
EOF
else
sudo -H -u ${arcgisuser} script/install.sh
fi

function autostart7(){  #arcgisserver  #server arcgisportal portal arcgisdatastore datastore
    if [ ! -f /etc/systemd/system/$1.service ]; then
        echo ""
        echo "==================================设置$1开机启动==================================="
        echo ""
        if [[ $2 == "portal" ]]; then
            script=/home/${arcgisuser}/arcgis/$2/framework/etc/$1.service
        else
            script=/home/${arcgisuser}/arcgis/$2/framework/etc/scripts/$1.service
        fi
        yes | cp -rf ${script} /etc/systemd/system
        systemctl enable $1.service
    #    systemctl stop arcgisserver.service
    #    systemctl start arcgisserver.service
        systemctl status $1.service
    fi
}

function autostart6(){  #arcgisserver  #server arcgisportal portal arcgisdatastore datastore
    echo ""
    echo "==================================设置$1开机启动==================================="
    echo ""
    if [[ $2 == "portal" ]]; then
        script=/home/${arcgisuser}/arcgis/$2/framework/etc/$1
        exp='s/portalhome=\/arcgis\/portal/portalhome=\/home\/'${arcgisuser}'\/arcgis\/portal/g'
        exp2='/# Description: Portal for ArcGIS Service/a # chkconfig: 35 99 01'
    else
        script=/home/${arcgisuser}/arcgis/$2/framework/etc/scripts/$1
        if [[ $2 == "server" ]]; then
            exp='s/agshome=\/arcgis\/server/agshome=\/home\/'${arcgisuser}'\/arcgis\/server/g'
            exp2='/# Description: ArcGIS Server Service/a # chkconfig: 35 99 01'
        else
            exp='s/datastorehome=\/arcgis\/datastore/datastorehome=\/home\/'${arcgisuser}'\/arcgis\/datastore/g'
            exp2='/# Description: ArcGIS Data Store Service/a # chkconfig: 35 99 01'
        fi
    fi

    if [[ ${OS_ID_Lower} == "redhatenterpriseserver" ]] || [[ ${OS_ID_Lower} == "centos" ]]; then
        yes | cp -rf ${script} /etc/rc.d/init.d/
        chmod 777 /etc/rc.d/init.d/$1
        sed -i -e "${exp}" /etc/rc.d/init.d/$1
        sed -i "${exp2}" /etc/rc.d/init.d/$1
        chkconfig --add /etc/rc.d/init.d/$1
        cd /etc/rc.d/init.d
#        chkconfig /etc/rc.d/init.d/$1 on
    elif [[ ${OS_ID_Lower} == "suse linux" ]];then
        yes | cp -rf ${script} /etc/init.d/
        chmod 777 /etc/init.d/$1
        sed -i -e "${exp}" /etc/init.d/$1
        insserv /etc/init.d/$1
        cd /etc/init.d
#        chkconfig /etc/init.d/$1 on
    fi
    chkconfig $1 on
}
echo ""
echo ""
echo "*********************************************************************************************"
echo "**|---------------------------------------------------------------------------------------|**"
echo "**|                    安装过程全部完毕，开始进行安装后配置                               |**"
echo "**|---------------------------------------------------------------------------------------|**"
echo "*********************************************************************************************"
echo ""
echo ""

if [[  ${OS_Release_Major} == '7' ]] || [[  ${OS_Release_Major} == '16' ]] || [[  ${OS_Release_Major} == '12' ]]; then
    autostart7 'arcgisserver' 'server'
    autostart7 'arcgisportal' 'portal'
    autostart7 'arcgisdatastore' 'datastore'
fi


if [[  ${OS_Release_Major} == '6' ]] || [[  ${OS_Release_Major} == '11' ]]; then
    originpath="$(pwd)"
    autostart6 'arcgisserver' 'server'
    autostart6 'arcgisportal' 'portal'
    autostart6 'arcgisdatastore' 'datastore'
    cd ${originpath}
fi




python script/postinstall.py ${newhostname}.${dnssuffix} ${arcgisuser} ${arcgisuserpwd}

echo ""
echo ""
echo "*********************************************************************************************"
echo "**|---------------------------------------------------------------------------------------|**"
echo "**|脚本运行完毕! 访问https://${newhostname}.${dnssuffix}:7443/arcgis/home                      |**"
echo "**|---------------------------------------------------------------------------------------|**"
echo "*********************************************************************************************"
echo ""
echo ""