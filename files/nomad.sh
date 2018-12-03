#!/bin/bash

supervisorctl stop nomad
rm -rf /var/log/nomad /etc/nomad /var/nomad

set -e

NOMAD_VERSION=0.8.6
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

mkdir -p /var/log/nomad
mkdir -p /etc/nomad
mkdir -p /var/nomad

cp /vagrant/nomad-server.hcl /etc/nomad
cp /vagrant/nomad-acl.hcl /etc/nomad
cp /vagrant/supervisor.nomad.conf /etc/supervisor/conf.d/nomad.conf

for i in nomad-ca.pem server.pem server-key.pem; do
  cp /tmp/nomad-pki/$i /etc/nomad
done

supervisorctl reread
supervisorctl update nomad
supervisorctl start nomad || true

NOMAD_PORT=4646
export NOMAD_ADDR=https://localhost:$NOMAD_PORT
 # Make sure nomad is up and running
while ! nc -z localhost $NOMAD_PORT; do
    sleep 1
done

export NOMAD_CACERT=/tmp/nomad-pki/nomad-ca.pem
export NOMAD_CLIENT_CERT=/tmp/nomad-pki/cli.pem
export NOMAD_CLIENT_KEY=/tmp/nomad-pki/cli-key.pem

CURL_TLS_ARGS="-E $NOMAD_CLIENT_CERT --key $NOMAD_CLIENT_KEY --cacert $NOMAD_CACERT"
INITIAL_MGMT_TOKEN=$(curl -s -X POST $CURL_TLS_ARGS $NOMAD_ADDR/v1/acl/bootstrap | jq -r .SecretID)
NOMAD_TOKEN=${INITIAL_MGMT_TOKEN} nomad acl policy apply anonymous /vagrant/nomad-acl-policy-anon.hcl
NOMAD_TOKEN=${INITIAL_MGMT_TOKEN} nomad acl policy apply writeany /vagrant/nomad-acl-policy-write.hcl

# Generate a child management token rather than using the initial token,
# which we'd rather never revoke.
NOMAD_MGMT_TOKEN=$(curl -s -X POST $CURL_TLS_ARGS \
  -H "X-Nomad-Token: $INITIAL_MGMT_TOKEN" \
  -d '{"Type": "management"}' \
  $NOMAD_ADDR/v1/acl/token | jq -r .SecretID)

# Remove any existing NOMAD env vars.
perl -i -n -e '/^NOMAD/ || print' /etc/environment

echo "NOMAD_ADDR=$NOMAD_ADDR" >> /etc/environment
echo "NOMAD_MGMT_TOKEN=$NOMAD_MGMT_TOKEN" >> /etc/environment
