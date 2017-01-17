# coding=utf-8

import json
import sys
import os
# import pwd
import pcurl
import urllib

# arcgis系统账户，站点管理员（siteadmin），portal管理员（portaladmin）的账号密码
fqdn = sys.argv[1]
username = sys.argv[2]
passwd = sys.argv[3]


def create_server_site():
    r = pcurl.get('https://' + fqdn + ':6443/arcgis/admin/createNewSite?f=json')
    payload = {'username': username, 'password': passwd,
               'configStoreConnection': json.dumps(r['configStoreConnection']),
               'directories': json.dumps(r['directories']), 'f': 'json'}
    print u'---------------------------------------------------------------------------------------------'
    print u'                                     开始创建Server站点'
    print u'---------------------------------------------------------------------------------------------'
    result = pcurl.post('https://' + fqdn + ':6443/arcgis/admin/createNewSite', payload)
    print u'---------------------------------------------------------------------------------------------'
    print u'                                     开始创建Server站点'
    print u'---------------------------------------------------------------------------------------------'
    print json.dumps(result)


def get_server_admin_token():
    payload = {'username': username, 'password': passwd, 'f': 'json', 'client': 'requestip'}
    result = pcurl.post('https://' + fqdn + ':6443/arcgis/admin/generateToken', payload)
    return result['token']


def delete_site(tt):
    payload = {'token': tt, 'f': 'json'}
    result = pcurl.post('https://' + fqdn + ':6443/arcgis/admin/deleteSite', payload)
    return result


def create_portal_site():
    r = pcurl.get('https://' + fqdn + ':7443/arcgis/portaladmin/createNewSite?f=json')
    payload = {'username': username, 'password': passwd, 'fullname': username, 'email': 'qqq@qq.com',
               'securityQuestionIdx': 1, 'securityQuestionAns': '222',
               'contentStore': json.dumps(
                   {'type': 'fileStore', 'provider': 'FileSystem', 'connectionString': r['contentDirPath']}),
               'f': 'json'}
    print u'---------------------------------------------------------------------------------------------'
    print u'                                     开始创建Portal站点'
    print u'---------------------------------------------------------------------------------------------'
    result = pcurl.post('https://' + fqdn + ':7443/arcgis/portaladmin/createNewSite', payload)
    print u'---------------------------------------------------------------------------------------------'
    print u'                                     Portal站点创建完成'
    print u'---------------------------------------------------------------------------------------------'
    print json.dumps(result)


def get_portal_token():
    payload = {'username': username, 'password': passwd, 'f': 'json', 'client': 'referer', 'referer': 'python://qqq'}
    result = pcurl.post('https://' + fqdn + ':7443/arcgis/sharing/generateToken', payload)
    return result['token']


# def fedrate_server(tt):
#     payload = {'url': 'https://' + fqdn + ':6443/arcgis', 'adminUrl': 'https://' + fqdn + ':6443/arcgis', 'f': 'json',
#                'username': username, 'token': tt,
#                'password': passwd}
#     result = requests.post('https://' + fqdn + ':7443/arcgis/portaladmin/federation/servers/federate', data=payload,
#                            verify=False).json()
#     print result


def federate_server():
    payload = {
        'username': username,
        'password': passwd}
    # result = requests.post('https://' + fqdn + ':7443/arcgis/portaladmin/login', data=payload,
    #                        verify=False)
    # session = requests.Session()
    # session.post('https://' + fqdn + ':7443/arcgis/portaladmin/login', data=payload,
    #              verify=False)
    #
    # cookies = session.cookies.get_dict()
    # print u'========================================='
    # print u'获取portal admin cookie：', cookies
    # print u'========================================='
    pcurl.getcookie('https://' + fqdn + ':7443/arcgis/portaladmin/login', payload)
    curlcmd = "curl 'https://" + fqdn + \
              ":7443/arcgis/portaladmin/federation/servers/federate' -b cookie -H 'Origin: https://" + fqdn + ":7443' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://" + fqdn + ":7443/arcgis/portaladmin/federation/servers/federate' -H 'Connection: keep-alive' --data 'url=https%3A%2F%2F" + fqdn + "%3A6443%2Farcgis&adminUrl=https%3A%2F%2F" + fqdn + "%3A6443%2Farcgis&username=" + username + "&password=" + passwd + "&f=html' --compressed -k"
    print u'---------------------------------------------------------------------------------------------'
    print u'                                       联合Server'
    print u'---------------------------------------------------------------------------------------------'
    os.system(curlcmd)
    os.remove('cookie')
    # token = json.loads(urllib.unquote(cookies['PORTAL_ADMIN_TOKEN']))['token']


# def setInterval(interval):
#     def decorator(function):
#         def wrapper(*args, **kwargs):
#             stopped = threading.Event()
#
#             def loop():  # executed in another thread
#                 while not stopped.wait(interval):  # until stopped
#                     function(*args, **kwargs)
#
#             t = threading.Thread(target=loop)
#             t.daemon = True  # stop if the program exits
#             t.start()
#             return stopped
#
#         return wrapper
#
#     return decorator
# http://stackoverflow.com/questions/12435211/python-threading-timer-repeat-function-every-n-seconds/16368571#16368571
# http://stackoverflow.com/questions/22498038/improve-current-implementation-of-a-setinterval-python/22498708#22498708

from threading import Event, Thread


def config_datastore():
    print u'---------------------------------------------------------------------------------------------'
    print u'                                      开始配置DataStore'
    print u'---------------------------------------------------------------------------------------------'
    if not os.path.isdir("/home/" + username + "/arcgis/datastore/usr/arcgisdatastore"):
        # newuid = pwd.getpwnam(username).pw_uid
        # os.setuid(newuid)
        os.system('sudo -u ' + username + ' mkdir -p ' + "/home/" + username + "/arcgis/datastore/usr/arcgisdatastore")
        os.system(
            'sudo -u ' + username + ' bash /home/' + username + '/arcgis/datastore/tools/configuredatastore.sh https://' + fqdn + ':6443/arcgis/admin ' + username + ' ' + passwd + ' /home/' + username + '/arcgis/datastore/usr/arcgisdatastore --stores relational,tileCache')

        print u'---------------------------------------------------------------------------------------------'
        print u'                                      DataStore配置完成'
        print u'---------------------------------------------------------------------------------------------'


def call_repeatedly(interval, func, *args):
    stopped = Event()

    def loop():
        while not stopped.wait(interval):  # the first call is in `interval` secs
            func(*args)

    Thread(target=loop).start()
    return stopped.set


def config_hosting_server(tt):
    result = pcurl.get('https://' + fqdn + ':7443/arcgis/portaladmin/federation/servers?f=json&token=' + tt)
    print result
    for server in result['servers']:
        if not server['isHosted']:
            print u'---------------------------------------------------------------------------------------------'
            print u'                            开始配置Server为托管服务器', server['id']
            print u'---------------------------------------------------------------------------------------------'
            payload = {
                'serverRole': 'HOSTING_SERVER',
                'token': tt, 'f': 'json'}
            r = pcurl.post(
                'https://' + fqdn + ':7443/arcgis/portaladmin/federation/servers/' + server['id'] + '/update',
                payload)
            print json.dumps(r)


def config_server_remove_hosting(tt):
    result = pcurl.get('https://' + fqdn + ':7443/arcgis/portaladmin/federation/servers?f=json&token=' + tt)
    print result
    for server in result['servers']:
        if server['isHosted']:
            print u'---------------------------------------------------------------------------------------------'
            print u'                           取消Server的托管', server['id']
            print u'---------------------------------------------------------------------------------------------'
            payload = {
                'serverRole': 'FEDERATED_SERVER',
                'token': tt, 'f': 'json'}
            r = pcurl.post(
                'https://' + fqdn + ':7443/arcgis/portaladmin/federation/servers/' + server['id'] + '/update',
                payload)
            print json.dumps(r)


def unfederate(tt):
    result = pcurl.get('https://' + fqdn + ':7443/arcgis/portaladmin/federation/servers?f=json&token=' + tt)
    print result
    for server in result['servers']:
        print u'---------------------------------------------------------------------------------------------'
        print u'                                取消Server联合', server['id']
        print u'---------------------------------------------------------------------------------------------'
        payload = {
            'token': tt, 'f': 'json'}
        r = pcurl.post(
            'https://' + fqdn + ':7443/arcgis/portaladmin/federation/servers/' + server['id'] + '/unfederate',
            payload)
        print json.dumps(r)


def check_portal_is_up(configHosting):
    try:
        if urllib.urlopen("https://" + fqdn + ":7443/arcgis/portaladmin/federation/servers/federate").getcode() == 200:
            cancel_future_calls()
            print u'---------------------------------------------------------------------------------------------'
            print u'                                     Portal重启成功'
            print u'---------------------------------------------------------------------------------------------'
            federate_server()
            if configHosting:
                ttt = get_portal_token()
                config_hosting_server(ttt)
            return
    except:
        pass
    print u'---------------------------------------------------------------------------------------------'
    print u'                                 等待Portal重启中……'
    print u'---------------------------------------------------------------------------------------------'


create_server_site()
create_portal_site()
config_datastore()

federate_server()
ttt = get_portal_token()
config_hosting_server(ttt)


# cancel_future_calls = call_repeatedly(25, check_portal_is_up, True)
# federate_server()
