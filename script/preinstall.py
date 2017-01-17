# coding=utf-8
import os
import pwd
import crypt
import sys
import pcurl

# 脚本参数设置区

# 主机名和 dns后缀
hostname = sys.argv[1]
dnssuffix = sys.argv[2]

# arcgis系统账户，站点管理员（siteadmin），portal管理员（portaladmin）的账号密码
agsuser = sys.argv[3]
passwd = sys.argv[4]
majorversion = sys.argv[5]
# 脚本参数设置区结束

fqdn = '.'.join([hostname, dnssuffix])

ip = os.popen(
    "ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '\.1$'").read()[
     :-1]
print u'---------------------------------------------------------------------------------------------'
print u'                                   本机IP', ip
print u'---------------------------------------------------------------------------------------------'
hostsRecord = '    '.join([ip, fqdn, hostname])
if majorversion == '11':
    f = open('/etc/HOSTNAME', 'w')
    f.write(hostname)
    f.close()
else:
    f = open('/etc/hostname', 'w')
    f.write(hostname)
    f.close()

print u'---------------------------------------------------------------------------------------------'
print u'                                  修改本机机器名为', hostname
print u'---------------------------------------------------------------------------------------------'

os.system('/bin/hostname ' + hostname)


def insert_records(filters, filepath, records):
    u"""添加记录，防止重复添加"""
    oldlines = os.popen('cat ' + filepath).read().split('\n')
    with open(filepath, 'w') as newfile:
        for line in oldlines:
            if not any(bad_word in line for bad_word in filters):
                newfile.write(line)
                newfile.write('\n')
        newfile.write('\n'.join(records))


print u'---------------------------------------------------------------------------------------------'
print u'                      增加/etc/hosts条目：', hostsRecord
print u'---------------------------------------------------------------------------------------------'

insert_records([hostname, fqdn], '/etc/hosts', [hostsRecord])

try:
    pwd.getpwnam(agsuser)
except KeyError:
    print u'---------------------------------------------------------------------------------------------'
    print u'                                开始创建arcgis账户：', agsuser
    print u'---------------------------------------------------------------------------------------------'
    os.system(
        "useradd -p " + crypt.crypt(passwd,
                                    "22") + " -s " + "/bin/bash " + "-d " + "/home/" + agsuser + " -m " + " -c \"" + agsuser + "\" " + agsuser)
else:
    print u'---------------------------------------------------------------------------------------------'
    print u'                                账户已存在：', agsuser
    print u'---------------------------------------------------------------------------------------------'


def openports_cent7(ports):
    print u'---------------------------------------------------------------------------------------------'
    print u'打开端口：', ','.join(ports)
    print u'---------------------------------------------------------------------------------------------'
    firewalld = os.popen('firewall-cmd --get-active-zones', 'r')
    zone_name = firewalld.readline()[:-1]
    firewalld.close()
    for port in ports:
        os.system('firewall-cmd --zone=' + zone_name + ' --add-port=' + port + '/tcp --permanent')
    print u'---------------------------------------------------------------------------------------------'
    print u'                                     正在保存防火墙设置'
    print u'---------------------------------------------------------------------------------------------'
    os.system('firewall-cmd --reload')


def openports_cent6(ports):
    print u'---------------------------------------------------------------------------------------------'
    print u'打开端口：', ','.join(ports)
    print u'---------------------------------------------------------------------------------------------'
    for port in ports:
        if '-' in port:
            os.system('iptables -A INPUT -p tcp --match multiport --dports ' + port.replace("-", ":") + ' -j ACCEPT')
        else:
            os.system('iptables -I INPUT -p tcp -m tcp --dport ' + port + ' -j ACCEPT')
    print u'---------------------------------------------------------------------------------------------'
    print u'                                     正在保存防火墙设置'
    print u'---------------------------------------------------------------------------------------------'
    os.system('service iptables save')


def openports_ubuntu(ports):
    print u'---------------------------------------------------------------------------------------------'
    print u'打开端口：', ','.join(ports)
    print u'---------------------------------------------------------------------------------------------'
    for port in ports:
        if '-' in port:
            os.system('ufw allow ' + port.replace("-", ":") + '/tcp')
        else:
            os.system('ufw allow ' + port)
    print u'---------------------------------------------------------------------------------------------'
    print u'                                     正在保存防火墙设置'
    print u'---------------------------------------------------------------------------------------------'
    # os.system('service iptables save')


def openports_sles(ports):
    print u'---------------------------------------------------------------------------------------------'
    print u'打开端口：', ','.join(ports)
    print u'---------------------------------------------------------------------------------------------'
    for port in ports:
        if ':' in port:
            os.system('iptables -A INPUT -p tcp --match multiport --dports ' + port + ' -j ACCEPT')
        else:
            os.system('iptables -I INPUT -p tcp -m tcp --dport ' + port + ' -j ACCEPT')
    print u'---------------------------------------------------------------------------------------------'
    print u'                                     正在保存防火墙设置'
    print u'---------------------------------------------------------------------------------------------'
    with open('/etc/sysconfig/SuSEfirewall2', 'r') as input_file:
        with open('/etc/sysconfig/SuSEfirewall3', 'w') as output_file:
            for line in input_file:
                if line.strip() == 'FW_SERVICES_EXT_TCP=""':
                    output_file.write('FW_SERVICES_EXT_TCP="' + ' '.join(ports) + '"\n')
                else:
                    output_file.write(line)
            from shutil import move
            move('/etc/sysconfig/SuSEfirewall3', '/etc/sysconfig/SuSEfirewall2')
            os.system('SuSEfirewall2')


if majorversion == '6':
    openports_cent6(
        ['1098', '4000-4004', '6006', '6080', '6099', '6443', '2443', '9876', '29080', '29081', '9220', '9320', '7080',
         '7443', '7005', '7099', '7199', '7654'])
elif majorversion == '11' or majorversion == '12':
    openports_sles(
        ['1098', '4000:4004', '6006', '6080', '6099', '6443', '2443', '9876', '29080', '29081', '9220', '9320', '7080',
         '7443', '7005', '7099', '7199', '7654'])
elif majorversion == '7':
    openports_cent7(
        ['1098', '4000-4004', '6006', '6080', '6099', '6443', '2443', '9876', '29080', '29081', '9220', '9320', '7080',
         '7443', '7005', '7099', '7199', '7654'])
elif majorversion == '16':
    openports_ubuntu(
        ['1098', '4000-4004', '6006', '6080', '6099', '6443', '2443', '9876', '29080', '29081', '9220', '9320', '7080',
         '7443', '7005', '7099', '7199', '7654'])
print u'---------------------------------------------------------------------------------------------'
print u'                                     修改limits文件'
print u'---------------------------------------------------------------------------------------------'
insert_records([agsuser], '/etc/security/limits.conf',
               [agsuser + ' soft nofile 65535', agsuser + ' hard nofile 65535', agsuser + ' soft nproc 25059',
                agsuser + ' hard nproc 25059'])

print u'---------------------------------------------------------------------------------------------'
print u'                                  修改/etc/sysctl.conf文件'
print u'---------------------------------------------------------------------------------------------'
insert_records(['max_map_count', 'swappiness'], '/etc/sysctl.conf', ['vm.max_map_count = 262144', 'vm.swappiness = 1'])
os.system('sysctl -p')

print u'---------------------------------------------------------------------------------------------'
print u'                                       设置系统时间'
print u'---------------------------------------------------------------------------------------------'
r = pcurl.get('http://www.worldtimeserver.com/handlers/GetData.ashx?action=GCTData')
os.system('date +%D -s '+r['ThisTime'][0:10])
os.system('date +%T -s '+r['DateTime_24HR'])
