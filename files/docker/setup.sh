#!/bin/bash

echo "Installing Docker..."
apt-get update
apt-get remove docker docker-engine docker.io
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
apt-get update
apt-get install -y docker-ce
# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
service docker restart
# Make sure we can actually use docker as the vagrant user
usermod -aG docker vagrant
docker --version
