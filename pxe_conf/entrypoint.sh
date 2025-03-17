#!/bin/bash

# Set up TFTP server
cat << EOF > /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
EOF
chown tftp:root /tftpboot -R
# Set up proxy DHCP
cat << EOF > /etc/dnsmasq.conf
# Disable DNS server
port=0 
# PROXY DHCP MODE 
bind-interfaces
log-dhcp
dhcp-no-override
dhcp-range=${PXE_IP},proxy
# Serving the PXE file
pxe-service=X86PC, "Boot BIOS PXE", pxelinux.0
EOF
# Replace PXE IP address
cd /tftpboot/pxelinux.cfg && 
sed $(echo 's/${PXE_IP}'"/${PXE_IP}/g") default.template > default
# Starting services
service tftpd-hpa restart
service dnsmasq restart
cd /tftpboot && python3 -m http.server 80 >/var/log/http.log 2>&1 &
wget localhost
cat /var/log/http.log
# Kepping the container running
tail -f /dev/null
