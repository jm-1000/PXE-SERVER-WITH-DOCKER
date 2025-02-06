#!/bin/bash
# Putting the given PXE server IP in the files 
envsubst < /tmp/dnsmasq.conf > /etc/dnsmasq.conf
envsubst < /tmp/default > /tftpboot/pxelinux.cfg/default
# Starting services
service tftpd-hpa restart
service dnsmasq restart
# Kepping the container running
tail -f /dev/null