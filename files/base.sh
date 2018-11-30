#!/bin/bash

#Set DEBIAN_FRONTEND as noninteractive. This is required to avoid the error
# dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

apt-get update

echo "Installing unzip and jq"
apt-get install -y -q unzip jq

echo "Installing supervisor"
apt-get install -y -q supervisor
apt-get install -y virtualenv python-pip
pip install --upgrade pip