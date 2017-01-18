#!/usr/bin/env bash
HAS_LSB="true"
[ ! -e /usr/bin/lsb_release ] && HAS_LSB="false"
getLinuxDistro()
{
  if [ "$HAS_LSB" = "true" ]; then
    echo "$(lsb_release -si)"
    return
  fi

  DISTRO="Unknown"

  if [ "$(uname -s)" = "Linux" ]; then
    #
    # CENTOS
    #
    if [ -f /etc/centos-release ]; then
      DISTRO="CentOS"
    #
    # ORACLE
    #
    elif [ -f /etc/oracle-release ]; then
      DISTRO="OracleServer"
    #
    # SCIENTIFIC
    #
    elif [ -f /etc/scientific-release ]; then
      DISTRO="Scientific"
    #
    # REDHAT
    #
    elif [ -f /etc/redhat-release ]; then
      if [ "$(grep -i 'Red Hat' /etc/redhat-release)" != "" ]; then
        DISTRO="RedHatEnterpriseServer"
      elif [ "$(grep -i 'CentOS' /etc/redhat-release)" != "" ]; then
        DISTRO="CentOS"
      elif [ "$(grep -i 'Scientific' /etc/redhat-release)" != "" ]; then
        DISTRO="Scientific"
      elif [ "$(grep -i 'Oracle' /etc/redhat-release)" != "" ]; then
        DISTRO="OracleServer"
      fi
    #
    # SUSE 11
    #
    elif [ -f /etc/SuSE-release ]; then
      DISTRO="SUSE LINUX"
    #
    # UBUNTU & SUSE12+
    #
    elif [ -f /etc/os-release ]; then
      if [ "$(grep -i 'Ubuntu' /etc/os-release)" != "" ]; then
        DISTRO="Ubuntu"
      fi
      if [ "$(grep -i 'SUSE' /etc/os-release)" != "" ]; then
        DISTRO="SUSE LINUX"
      fi
    fi
  else
    echo "Unsupported OS"
    return
  fi

  echo "$DISTRO"
}


getOSVersion()
{
  if [ "$HAS_LSB" = "true" ]; then
    echo "$(lsb_release -sr)"
    return
  fi

  VERSION="Unknown"

  if [ "$(uname -s)" = "Linux" ]; then
    #
    # CENTOS
    #
    if [ -f /etc/centos-release ]; then
      VERSION=`cat /etc/centos-release | sed s/.*release\ // | sed s/\ .*//`
    #
    # ORACLE
    #
    elif [ -f /etc/oracle-release ]; then
      VERSION=`cat /etc/oracle-release | sed s/.*release\ // | sed s/\ .*//`
    #
    # SCIENTIFIC
    #
    elif [ -f /etc/scientific-release ]; then
      VERSION=`cat /etc/scientific-release | sed s/.*release\ // | sed s/\ .*//`
    #
    # REDHAT
    #
    elif [ -f /etc/redhat-release ]; then
      VERSION=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    #
    # SUSE
    #
    elif [ -f /etc/SuSE-release ]; then
      VERSION=`cat /etc/SuSE-release | grep VERSION | awk '{print $NF}'`
    #
    # UBUNTU
    #
    elif [ -f /etc/os-release ]; then
      VERSION=`cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | sed 's/\"//g'`
    fi
  else
    echo "Unsupported OS"
    return
  fi

  echo "$VERSION"
}

export OS_ID=$(getLinuxDistro)
export OS_ID_Lower=$(echo $OS_ID | tr "[A-Z]" "[a-z]")
export OS_Release=$(getOSVersion)
export OS_Release_Major=$(echo $OS_Release | cut -d"." -f1)
export OS_Release_Minor=$(echo $OS_Release | cut -d"." -f2)

#echo OS_ID $OS_ID
#echo OS_ID_Lower $OS_ID_Lower
#echo OS_Release $OS_Release
#echo OS_Release_Major $OS_Release_Major
#echo OS_Release_Minor $OS_Release_Minor

RedHat6PackageList="fontconfig freetype libICE libSM libXtst libXrender glib2 gettext dos2unix"
RedHat7PackageList="fontconfig freetype libICE libSM libXtst libXrender glib2 gettext dos2unix"
Suse11PackageList="fontconfig freetype  xorg-x11-libSM xorg-x11-libXrender glib2 gettext-runtime dos2unix"
Suse12PackageList="fontconfig freetype libSM6 libXrender1 glib2-devel gettext-runtime dos2unix"
Ubuntu16PackageList="fontconfig libffi6 libice6 libsm6 libxtst6 libxrender1 libglib2.0-0 gettext-base dos2unix"

PackageList=""

case ${OS_ID_Lower} in
  "redhatenterpriseserver"|"redhatenterprisees"|"oracleserver"|"centos"|"scientific")
    case $OS_Release_Major in 
      6)
        PackageList=$RedHat6PackageList
        ;;
      7)
        PackageList=$RedHat7PackageList
        ;;
    esac
    ;;
  "suse linux")
    case $OS_Release_Major in
      11)
        PackageList=$Suse11PackageList
        ;;
      12)
        PackageList=$Suse12PackageList
        ;;
    esac
    ;;
  "ubuntu")
    case $OS_Release_Major in
      14|16)
        PackageList=$Ubuntu16PackageList
        ;;
    esac
    ;;
esac

has_missing="false"
for package in $PackageList
do
  if [[ ${OS_ID_Lower} != 'ubuntu' ]]; then
    rpm -q $package > /dev/null 2>&1
  else
    dpkg -l $package > /dev/null 2>&1
  fi
  if [ $? -ne 0 ]; then
	echo ${package}'没有安装'
	has_missing="true"
	#apt-get install ${package} -y
    #rpm -ivh package/${package}*.rpm
  fi
done
