#!/bin/sh

# clear
iptables -t nat -F REDSOCKS
iptables -t nat -X REDSOCKS

iptables -t nat -N REDSOCKS

# exclude IPs
# dnscrypt-proxy cisco
#iptables -t nat -A REDSOCKS -d 208.67.220.220 -j RETURN
# proxy servers
iptables -t nat -A REDSOCKS -d 1.1.1.1 -j RETURN

# Ignore LANs IP address
iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN

iptables -t nat -A REDSOCKS -j CN_RETURN
iptables -t nat -A CN_RETURN -p tcp -j REDIRECT --to-port 1082

iptables -t nat -A PREROUTING -p tcp -m multiport --dports 80,443 -j REDSOCKS

