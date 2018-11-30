#!/bin/bash

set -e

vault login $VAULT_ADMIN_TOKEN

# Configure Vault for the poc app.
vault policy write secret /vagrant/acl.hcl
vault write /auth/token/roles/nomad-cluster @/vagrant/nomad-cluster-role.json
vault policy write nomad-server /vagrant/nomad-server-policy.hcl
vault kv put secret/password value=12345

# Configure Vault's Nomad secret engine.
vault secrets list |grep -q nomad/ || vault secrets enable nomad
vault write nomad/config/access address=$NOMAD_ADDR token=$NOMAD_MGMT_TOKEN
vault write nomad/role/writeany policies=writeany
echo 'path "nomad/creds/writeany" { capabilities = ["read"] }' | vault policy write nomad-user-policy -

# Get a vault token that can be used to get a nomad token by reading from nomad/creds/writeany.
VAULT_TOKEN_NOMAD_USER=$(vault token create -policy=nomad-user-policy -field token)

# Remove any existing VAULT_TOKEN_NOMAD_USER env vars.
perl -i -n -e '/^VAULT_TOKEN_NOMAD_USER/ || print' /etc/environment

echo "VAULT_TOKEN_NOMAD_USER=$VAULT_TOKEN_NOMAD_USER" >> /etc/environment
