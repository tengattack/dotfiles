#!/usr/bin/env python

import os
import urllib2
from cStringIO import StringIO
import gzip
import zlib

# gzip opener
opener = urllib2.build_opener()
opener.addheaders = [ ('Accept-Encoding', 'gzip, deflate') ]

countries={'CN': 'CN_RETURN'}

def request(url):
    resp = opener.open(url)
    encoding = resp.info().get("Content-Encoding")
    d = None
    if encoding in ('gzip', 'x-gzip', 'deflate'):
        content = resp.read()
        if encoding == 'deflate':
            data = StringIO.StringIO(zlib.decompress(content))
        else:
            data = gzip.GzipFile('', 'rb', 9, StringIO.StringIO(content))
        d = data.read()
    else:
    	d = resp.read().decode('utf-8')
    resp.close()
    return d

#os.system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin")
for country in countries.keys():
    url = "http://www.ipdeny.com/ipblocks/data/aggregated/%s-aggregated.zone" % country.lower()

    # configure iptables
    os.system("iptables -t nat -F %s" % countries[country])
    os.system("iptables -t nat -X %s" % countries[country])
    os.system("iptables -t nat -N %s" % countries[country])

    # configure ipset
    os.system("ipset -X %s_IPs" % country)

    setlines = "create %s_IPs hash:net family inet hashsize 1024 maxelem 65536\n" % country

    # fetch ips
    print("downloading (%s)..." % url)
    data = request(url)
    if not data:
        print("download failed.")
        continue
    for ip in data.split('\n'):
        if ip.rstrip():
            setlines += "add %s_IPs %s\n" % (country, ip.rstrip())

    # save ipset file
    filepath = "./%s_IPs.ipset" % country
    f = open(filepath, 'wb+')
    f.write(setlines)
    f.close()

    # restore ipset
    print("restoring ipset...")
    os.system("ipset -R < %s" % filepath)
    # match set
    os.system("iptables -t nat -A %s -m set --match-set %s_IPs dst -j RETURN" % (countries[country], country))

#os.system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit")
#os.system("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end")


