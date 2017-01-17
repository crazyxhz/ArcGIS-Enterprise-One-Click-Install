#!/usr/bin/env bash
source config.sh
echo ""
echo ""
echo "************************************************************************************"
echo "*                                                                                  *"
echo "*                                  进行ArcGIS安装                                   *"
echo "*                                                                                  *"
echo "************************************************************************************"
echo ""
echo ""
ulimit -n 65535
ulimit -u 25059
echo "Hard limits:"
ulimit -Hn -Hu
echo "Soft limits:"
ulimit -Sn -Su
filename=$(basename "$licensefullpath")
#echo "bash Setup -m silent -l yes -a /home/${arcgisuser}/${filename} -d /home/${arcgisuser}/arcgis/server"
# Server 安装
if [ ! -d ~/unpacked/server ]; then
    mkdir -p ~/unpacked/server
    echo ""
    echo "==============================开始解压Server安装介质=============================="
    echo ""
    tar zxf /mnt/arcgiscd/ArcGIS_Server_Linux_105_154052.tar.gz -C ~/unpacked/server
    echo ""
    echo "====================开始安装ArcGIS Server(静默安装)========================="
    echo ""
    cd ~/unpacked/server/ArcGISServer
    bash Setup -m silent -l yes -a /home/${arcgisuser}/${filename} -d /home/${arcgisuser}/arcgis/server
    echo ""
    echo "=========================ArcGIS Server 安装完毕========================="
    echo ""
fi

# Portal 安装
if [ ! -d ~/unpacked/portal ]; then
    mkdir -p ~/unpacked/portal
    echo ""
    echo "==============================开始解压Portal安装介质=============================="
    echo ""
    tar zxf /mnt/arcgiscd/Portal_for_ArcGIS_Linux_105_154053.tar.gz -C ~/unpacked/portal
    echo ""
    echo "==============================开始安装Portal(静默安装)=============================="
    echo ""
    cd ~/unpacked/portal/PortalForArcGIS
    bash Setup -m silent -l yes -a /home/${arcgisuser}/${filename}
    echo ""
    echo "==============================Portal 安装完毕=============================="
    echo ""
fi

# DataStore 安装
if [ ! -d ~/unpacked/datastore ]; then
    mkdir -p ~/unpacked/datastore
    echo ""
    echo "=========================开始解压DataStore安装介质=============================="
    echo ""
    tar zxf /mnt/arcgiscd/ArcGIS_DataStore_Linux_105_154054.tar.gz -C ~/unpacked/datastore
    echo ""
    echo "====================解压完毕，开始安装DataStore(静默安装)===================="
    echo ""
    cd ~/unpacked/datastore/ArcGISDataStore_Linux
    bash Setup -m silent -l yes
    echo ""
    echo "=========================DataStore 安装完毕=============================="
    echo ""
fi