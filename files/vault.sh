#!/bin/bash

set -e

supervisorctl stop vault >/dev/null 2>&1
rm -rf /var/log/vault /etc/vault /var/vault

VAULT_VERSION=0.11.5
VAULT_ARCH=linux_amd64
VAULT_ZIP=vault_${VAULT_VERSION}_${VAULT_ARCH}.zip
VAULT_ZIP_FLAG=${VAULT_ZIP}.valid
VAULT_ADMIN_TOKEN=1e9e1f5a-3c23-a5d2-d308-ed2c3dd541c4
export VAULT_ADDR=http://localhost:8200

# Remove any existing VAULT_ADDR/VAULT_ADMIN_TOKEN env var.
perl -i -n -e '/^VAULT_(ADDR|ADMIN_TOKEN)=/ || print' /etc/environment

echo "VAULT_ADDR=$VAULT_ADDR" >> /etc/environment
echo "VAULT_ADMIN_TOKEN=$VAULT_ADMIN_TOKEN" >> /etc/environment

echo "Getting vault binary"

cd /tmp
if test -e "$VAULT_ZIP_FLAG"
then zflag="-z $VAULT_ZIP_FLAG"
else zflag=
fi
curl -s $zflag -R -O https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}
unzip -o /tmp/$VAULT_ZIP
mv vault /usr/local/bin/vault
touch $VAULT_ZIP_FLAG

mkdir -p /var/log/vault
mkdir -p /etc/vault
mkdir -p /var/vault

cp /vagrant/supervisor.vault.conf /etc/supervisor/conf.d/vault.conf

supervisorctl reread
supervisorctl update vault
supervisorctl start vault || true

 # Make sure vault is up and running
while ! curl $VAULT_ADDR >& /dev/null; do
    sleep 1
done

while [ "$TOKEN" == "" ]; do
    TOKEN=$(grep 'Root Token' /var/log/vault/out | tail -n1 | awk '{print $3}')
    sleep 1
done

while ! VAULT_TOKEN=$TOKEN vault token create -id="$VAULT_ADMIN_TOKEN"; do
    sleep 1
done
