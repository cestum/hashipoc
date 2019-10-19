#!/bin/bash

pip install -r /vagrant/app/requirements.txt
cp /vagrant/app/app.py /usr/local/bin

set -e

INSTANCE_IP="$(/sbin/ifconfig eth1 | grep 'inet addr:' | awk '{print substr($2,6)}')"

VAULT_TOKEN_NOMAD_USER=$(curl -sf GET 127.0.0.1:8500/v1/kv/service/vault/vault_token_for_nomad_user/$INSTANCE_IP?raw)
echo "Getting Nomad token using vault token $VAULT_TOKEN_NOMAD_USER"
export NOMAD_TOKEN=$(VAULT_TOKEN=$VAULT_TOKEN_NOMAD_USER vault read -field secret_id nomad/creds/writeany) 
echo "nomad token $NOMAD_TOKEN"
echo "Deleting any existing nomad job ..."
nomad job stop -purge helloworld || true

echo "Running nomad job ..."
nomad run /vagrant/app/helloworld.nomad

echo "Waiting for the deployment to complete ..."
while ! nomad job status helloworld | grep 'Deployment completed successfully' ; do
    sleep 1
done

ALLOC_ID=$(nomad job status helloworld | grep -A2 Allocations | tail -n1 | awk '{print $1}')
ENDPOINT=$(nomad alloc-status $ALLOC_ID | grep http: | sed 's/^.*http: //')
echo "Curling hello world server at ${ENDPOINT}"
curl -s http://${ENDPOINT}
echo
echo "while [ 1 ] ; do curl http://localhost ; sleep 1 ; done"
