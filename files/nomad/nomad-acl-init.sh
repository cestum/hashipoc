#!/bin/bash







INSTANCE_IP="$(/sbin/ifconfig eth1 | grep 'inet addr:' | awk '{print substr($2,6)}')"
NOMAD_PORT=4646
export NOMAD_ADDR=https://$INSTANCE_IP:$NOMAD_PORT
 # Make sure nomad is up and running
while ! nc -z $INSTANCE_IP $NOMAD_PORT; do
    sleep 1
done

export NOMAD_CACERT=/etc/nomad/nomad-ca.pem
export NOMAD_CLIENT_CERT=/etc/nomad/client/client.pem
export NOMAD_CLIENT_KEY=/etc/nomad/client/client-key.pem


##Configure nomad acl policies
echo "uploading policies to nomad"

CURL_TLS_ARGS="-E $NOMAD_CLIENT_CERT --key $NOMAD_CLIENT_KEY --cacert $NOMAD_CACERT"
TEMP_RESP=$(curl -s -X POST $CURL_TLS_ARGS $NOMAD_ADDR/v1/acl/bootstrap)
echo "$TEMP_RESP"

if [[ $TEMP_RESP == *"already done"* ]]; then
  
  NOMAD_MGMT_TOKEN=$(curl -sf GET 127.0.0.1:8500/v1/kv/service/vault/nomad_mgmt_token/$INSTANCE_IP?raw | jq -r .SecretID )
  echo "Using existing management token...$NOMAD_MGMT_TOKEN"
else

  INITIAL_MGMT_TOKEN=$(echo $TEMP_RESP | jq -r .SecretID)
  echo "Got initial mgmt token $INITIAL_MGMT_TOKEN"
  NOMAD_TOKEN=${INITIAL_MGMT_TOKEN} nomad acl policy apply anonymous /vagrant/nomad/nomad-acl-policy-anon.hcl
  NOMAD_TOKEN=${INITIAL_MGMT_TOKEN} nomad acl policy apply writeany /vagrant/nomad/nomad-acl-policy-write.hcl

  echo "Generating nomad mgmt"
  # Generate a child management token rather than using the initial token,
  # which we'd rather never revoke.
  NOMAD_MGMT_TOKEN=$(curl -s -X POST $CURL_TLS_ARGS \
    -H "X-Nomad-Token: $INITIAL_MGMT_TOKEN" \
    -d '{"Type": "management"}' \
    $NOMAD_ADDR/v1/acl/token)

  #store mgmt token in consul just in case!
  curl -sfX PUT 127.0.0.1:8500/v1/kv/service/vault/nomad_mgmt_token/$INSTANCE_IP -d $NOMAD_MGMT_TOKEN

  NOMAD_MGMT_TOKEN=$(echo $NOMAD_MGMT_TOKEN | jq -r .SecretID)
fi


export VAULT_ADDR=http://active.vault.service.consul:8200
cget() { curl -sf "http://127.0.0.1:8500/v1/kv/service/vault/$1?raw"; }

if [ $(cget root-token) ]; then
  export ROOT_TOKEN=$(cget root-token)
else
  echo "No ROOT token found"
  exit
fi

vault login $ROOT_TOKEN


# Configure Vault's Nomad secret engine.
vault secrets list |grep -q nomad/ || {
  echo "Vault's nomad engine doesn't exists..."
  vault secrets enable nomad
  vault write nomad/config/access address=$NOMAD_ADDR token=$NOMAD_MGMT_TOKEN
  vault write nomad/role/writeany policies=writeany
  echo 'path "nomad/creds/writeany" { capabilities = ["read"] }' | vault policy write nomad-user-policy -
}
# Get a vault token that can be used to get a nomad token by reading from nomad/creds/writeany.
VAULT_TOKEN_NOMAD_USER=$(vault token create -policy=nomad-user-policy -field token)
echo "Got Vault token for nomad apis $VAULT_TOKEN_NOMAD_USER"
# Remove any existing VAULT_TOKEN_NOMAD_USER env vars.
perl -i -n -e '/^VAULT_TOKEN_NOMAD_USER/ || print' /etc/environment
curl -sfX PUT 127.0.0.1:8500/v1/kv/service/vault/vault_token_for_nomad_user/$INSTANCE_IP -d $VAULT_TOKEN_NOMAD_USER


#APP specific
vault secrets list |grep -q secret/ || vault secrets enable -version=2 -path=secret/ kv

vault kv get secret/password || {
  vault kv put secret/password value=12345
  #secret policy for helloworld job
  vault policy write secret /vagrant/app/acl.hcl
}
#TODO store it in vault
# Remove any existing NOMAD env vars.
perl -i -n -e '/^NOMAD/ || print' /etc/environment

echo "NOMAD_ADDR=$NOMAD_ADDR" >> /etc/environment
#echo "VAULT_TOKEN_NOMAD_USER=$VAULT_TOKEN_NOMAD_USER" >> /etc/environment

