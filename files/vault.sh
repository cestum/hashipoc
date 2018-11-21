#!/bin/bash

VAULT_VERSION=0.11.5
VAULT_ARCH=linux_amd64

echo "Getting vault binary"
wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_${VAULT_ARCH}.zip -O /tmp/vault_${VAULT_VERSION}_${VAULT_ARCH}.zip
cd /tmp
unzip -o /tmp/vault_${VAULT_VERSION}_${VAULT_ARCH}.zip
mv vault /usr/local/bin/vault

mkdir -p /var/log/vault
mkdir -p /etc/vault
mkdir -p /var/vault

cp /vagrant/supervisor.vault.conf /etc/supervisor/conf.d/vault.conf
cp /vagrant/vault-wrapper.sh /usr/local/bin/vault-wrapper.sh

supervisorctl reread
supervisorctl update vault

sleep 5
