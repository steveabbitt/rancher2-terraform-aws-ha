#!/bin/bash

set -exu

echo "############ Update System ############"
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

echo "############ Installing Docker ############"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce=17.03.2~ce-0~ubuntu-xenial
usermod -g docker ubuntu
docker --version

echo "############ Installing fail2ban ############"
apt-get install -y fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed 's/bantime  = 600/bantime = 1800/' /etc/fail2ban/jail.local
fail2ban-client reload
fail2ban-client status

echo "############ Download Rancher Setup Tools ############"
wget https://github.com/rancher/rke/releases/download/v0.1.8/rke_linux-amd64 -O /home/ubuntu/rke
chown ubuntu:ubuntu /home/ubuntu/rke
chmod +x /home/ubuntu/rke