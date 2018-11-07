#! /usr/bin/python

url = 'http://localhost:8080/version'
timeout = 3

try:
    import urllib2
    request = urllib2.Request(url)
    response = urllib2.urlopen(request, timeout=timeout)
    if response.code == 200:
        exit(0)
except Exception as e:
    print(e)
    exit(1)
