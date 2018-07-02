import urllib2


URL = 'http://localhost:8080/'
TIMEOUT = 1
EXIT_CODE = 1

response = None

try:
    request = urllib2.Request(URL)
    response = urllib2.urlopen(request, timeout=TIMEOUT)
    if response.code == 200:
        EXIT_CODE = 0
except Exception as e:
    pass

print('Exiting with code %s' % EXIT_CODE)
exit(EXIT_CODE)