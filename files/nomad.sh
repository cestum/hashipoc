#!/bin/bash

supervisorctl stop nomad
rm -rf /var/log/nomad /etc/nomad /var/nomad

set -e

NOMAD_VERSION=0.8.6
NOMAD_ARCH=linux_amd64

echo "Getting nomad binary"
wget -q https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_${NOMAD_ARCH}.zip -O /tmp/nomad_${NOMAD_VERSION}_${NOMAD_ARCH}.zip
cd /tmp
unzip -o /tmp/nomad_${NOMAD_VERSION}_${NOMAD_ARCH}.zip
mv nomad /usr/local/bin/nomad

mkdir -p /var/log/nomad
mkdir -p /etc/nomad
mkdir -p /var/nomad

cp /vagrant/nomad-acl.hcl /etc/nomad
cp /vagrant/supervisor.nomad.conf /etc/supervisor/conf.d/nomad.conf

supervisorctl reread
supervisorctl update nomad
supervisorctl start nomad || true

export NOMAD_ADDR=http://localhost:4646
 # Make sure nomad is up and running
while ! curl $NOMAD_ADDR >& /dev/null; do
    sleep 1
done

INITIAL_MGMT_TOKEN=$(curl -s -X POST $NOMAD_ADDR/v1/acl/bootstrap | jq -r .SecretID)
NOMAD_TOKEN=${INITIAL_MGMT_TOKEN} nomad acl policy apply anonymous /vagrant/nomad-acl-policy-anon.hcl
NOMAD_TOKEN=${INITIAL_MGMT_TOKEN} nomad acl policy apply writeany /vagrant/nomad-acl-policy-write.hcl

# Generate a child management token rather than using the initial token,
# which we'd rather never revoke.
NOMAD_MGMT_TOKEN=$(curl -s -X POST \
  -H "X-Nomad-Token: $INITIAL_MGMT_TOKEN" \
  -d '{"Type": "management"}' \
  $NOMAD_ADDR/v1/acl/token | jq -r .SecretID)

# Remove any existing NOMAD env vars.
perl -i -n -e '/^NOMAD/ || print' /etc/environment

echo "NOMAD_ADDR=$NOMAD_ADDR" >> /etc/environment
echo "NOMAD_MGMT_TOKEN=$NOMAD_MGMT_TOKEN" >> /etc/environment
