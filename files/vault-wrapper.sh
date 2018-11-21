#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8200
truncate -s 0 /var/log/vault/out

(
TOKEN=
while [ "$TOKEN" == "" ]; do
  TOKEN=$(grep 'Root Token' /var/log/vault/out | tail -n1 | awk '{print $3}')
  sleep 1
done
echo $TOKEN | vault login -
vault token create -id="1e9e1f5a-3c23-a5d2-d308-ed2c3dd541c4"
vault login 1e9e1f5a-3c23-a5d2-d308-ed2c3dd541c4
vault policy write secret /vagrant/acl.hcl
vault write /auth/token/roles/nomad-cluster @/vagrant/nomad-cluster-role.json
vault policy write nomad-server /vagrant/nomad-server-policy.hcl
echo -n "12345" | vault kv put secret/password value=-
)&

/usr/local/bin/vault server -config=/etc/vault -dev