#!/bin/bash

pip install -r /vagrant/requirements.txt
cp /vagrant/app.py /usr/local/bin

set -e

echo "Getting Nomad token from Vault"
export NOMAD_TOKEN=$(VAULT_TOKEN=$VAULT_TOKEN_NOMAD_USER vault read -field secret_id nomad/creds/writeany) 

echo "Deleting any existing nomad job ..."
nomad job stop -purge helloworld || true

echo "Running nomad job ..."
nomad run /vagrant/helloworld.nomad

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
