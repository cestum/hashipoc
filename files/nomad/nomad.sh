#!/bin/bash

supervisorctl stop nomad
rm -rf /var/log/nomad /etc/nomad /var/nomad

set -e

NOMAD_VERSION=0.10.1
NOMAD_ARCH=linux_amd64
NOMAD_ZIP=nomad_${NOMAD_VERSION}_${NOMAD_ARCH}.zip 
NOMAD_ZIP_FLAG=${NOMAD_ZIP}.valid

echo "Getting nomad binary"
cd /tmp
if test -e "$NOMAD_ZIP_FLAG"
then zflag="-z $NOMAD_ZIP_FLAG"
else zflag=
fi
curl -s $zflag -R -O https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${NOMAD_ZIP}

unzip -o /tmp/$NOMAD_ZIP
touch -r $NOMAD_ZIP $NOMAD_ZIP_FLAG
mv nomad /usr/local/bin/nomad


INSTANCE_IP="$(/sbin/ifconfig eth1 | grep 'inet addr:' | awk '{print substr($2,6)}')"

mkdir -p /opt/nomad/data/server
mkdir -p /opt/nomad/data/client
mkdir -p /var/log/nomad
#mkdir -p /etc/nomad
mkdir -p /etc/nomad/client
mkdir -p /var/nomad

cp /vagrant/nomad/nomad-server.hcl /etc/nomad/nomad-server.hcl
cp /vagrant/nomad/nomad-client.hcl /etc/nomad/nomad-client.hcl
cp /vagrant/nomad/supervisor.nomad.conf /etc/supervisor/conf.d/nomad.conf

#service to check vault is ready - vault server needs it
cp /vagrant/nomad/is_vault_initialized.sh /usr/bin/is_vault_initialized.sh
chmod +x /usr/bin/is_vault_initialized.sh
cp /vagrant/nomad/supervisor.vault-ready.conf /etc/supervisor/conf.d/vault-ready.conf


##Certificates
for i in nomad-ca.pem server.pem server-key.pem; do
  cp /tmp/nomad-pki/$i /etc/nomad
done

for i in client.pem client-key.pem; do
  cp /tmp/nomad-pki/$i /etc/nomad/client
done

supervisorctl reread
supervisorctl update nomad
supervisorctl update vault-ready
