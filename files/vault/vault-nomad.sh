#!/bin/bash

set -e
set -v
set -x

export VAULT_ADDR=http://127.0.0.1:8200
cget() { curl -sf "http://127.0.0.1:8500/v1/kv/service/vault/$1?raw"; }

if [ $(cget root-token) ]; then
  export ROOT_TOKEN=$(cget root-token)
else
  echo "No ROOT token found"
  exit
fi

vault login $ROOT_TOKEN


# Generate a vault token for nomad
vault policy write nomad-server /vagrant/nomad/nomad-server-policy.hcl
#cluster role
vault write /auth/token/roles/nomad-cluster @/vagrant/nomad/nomad-cluster-role.json

#This token is for nomad. NOMAD (jobs and tasks) talks to vault using this token (check vault stanza in nomad server config)
VAULT_TOKEN_FOR_NOMAD=$(vault token create -policy nomad-server -period 72h -orphan | awk 'FNR == 3 {print$2}')
curl -sfX PUT 127.0.0.1:8500/v1/kv/service/vault/vault_token_for_nomad -d $VAULT_TOKEN_FOR_NOMAD

#now ready to configure nomad with vault 
#apply nomad-vault.hcl configuration (currently in consul-template)
#config already copied in consul-template.sh
supervisorctl start consul-template-vault
