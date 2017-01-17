# coding=utf-8

import os
import json
import urllib

# link = 'https://cen7.vm:6443/arcgis/rest/?f=pjson'


def get(url):
    cmd = "curl '" + url + "' -H 'Accept-Encoding: gzip, deflate, sdch, br' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' --compressed -k -sS"
    output = json.loads(os.popen(cmd).read())
    return output


def post(url, data):
    cmd = "curl '" + url + "' -H 'Origin: chrome-extension://fdmmgilgnpjigdojojpjoooidkmcomcm' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' --data '" + urllib.urlencode(
        data) + "' --compressed -k -sS"
    output = json.loads(os.popen(cmd).read())
    return output

def getcookie(url, data):
    cmd = "curl '" + url + "' -H 'Origin: chrome-extension://fdmmgilgnpjigdojojpjoooidkmcomcm' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' --data '" + urllib.urlencode(
        data) + "' --compressed -k -sS -c cookie"
    os.popen(cmd)


# print post('https://cen7.vm:7443/arcgis/sharing/generateToken',
#            {'username': 'arcgis', 'password': 'Super123', 'f': 'json', 'client': 'referer', 'referer': 'python://qqq'})
