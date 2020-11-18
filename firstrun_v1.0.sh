#!/bin/bash

# I've used this for years to get a CENTOS 7 OS configured quickly
# - Run this and it will ask for FQDN and IP and then...
# - Checks if IP is in use and quits if it is
# - Installs vmware tools
# - Stops and disables network manager so IP configurtaion is old school (simple!)
# - Installs network tools so legacy commands and utilities can be used.
# - Sets DNS servers in resolv.conf. Make sure they are what you need for your env.
# - Installs nslookup for troubleshooting if needed. 
# - Sets the hostname to what you put in for the FQDN
# - Sets the IP address to what you put in  for the IP
# - Sets the time zone. Adjust this to what you need. 
# - Installs NTP for time synchronization
# - Reboots

# Get fqdn and ip of server
read -p "Enter the FQDN hostname for this server: " fqdn_name
read -p "Enter the IP address for this server: " ip_address

# Check if IP provided pings
echo "this will ping if  address $ip_address is reachable"
sleep 2
ping -c 1 $ip_address
if  [ ${?} = 0 ]
then
  echo "IP is in use. Stopping..."
  exit
else
  echo "IP is not in use. Continuing..."
sleep 2
fi

#Exit on any subsequent errors
set -e

# Install vmware tools
echo '########### Installing vmware tools'
yum install open-vm-tools -y

# Stop network manager
echo '########### Stopping network manager'
systemctl stop NetworkManager

# Disable network manager
echo '########### Disabling network manager'
systemctl disable NetworkManager

# Install network tools for traditional network commands
echo '########## Installing network tools'
yum install net-tools -y
echo 'Checking the ifconfig command'
ifconfig

# Update name servers
echo '########### Setting up resolv.conf'
echo 'nameserver 192.168.0.41' > /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
cat /etc/resolv.conf

# Install nslookup
echo '########### Installing DNS tools'
yum install bind-utils -y

# Set hostname
echo '########### Setting hostname'
hostnamectl set-hostname $fqdn_name --static

# Setup static IP
echo '########### Creating ifcfg file for static IP'
file='/etc/sysconfig/network-scripts/ifcfg-ens192'
echo 'IPADDR='$ip_address > $file
echo 'NETMASK=255.255.255.0
GATEWAY=192.168.0.1
ONBOOT=yes
BOOTPROTO=static
DEVICE=ens192' >> $file

# Set timezone
echo '########### Setting timezone '
timedatectl set-timezone America/Los_Angeles
timedatectl status

# Set NTP
echo '############### setting up ntp '
yum install ntp -y
systemctl enable ntpd
systemctl start ntpd
date

echo '########### DONE ##########'
# Rebooting
echo 'rebooting...'
sleep 4
reboot

