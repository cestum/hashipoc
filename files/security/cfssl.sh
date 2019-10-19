#!/bin/bash

#set -e

export SSH_AUTH_SOCK=""
# export GOPATH=/usr/local/cfssl
# PATH=$PATH:/$GOPATH/bin

# /usr/local/go/bin/go get -v -u -f -insecure github.com/cloudflare/cfssl/cmd/...


for bin in cfssl cfssl-certinfo cfssljson
do
  echo "Installing $bin..."
  curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
  sudo install /tmp/${bin} /usr/local/bin/${bin}
done
echo "CFSSL Installed `cfssl version`"

rm -rf /tmp/nomad-pki
rm -rf /etc/nomad/*.pem

echo "making tmp directory"
# See https://www.nomadproject.io/guides/security/securing-nomad.html
mkdir -p /tmp/nomad-pki
cd /tmp/nomad-pki


#cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare nomad-ca
cp /vagrant/security/*.pem .
cp /vagrant/security/*.csr .

cat - > cfssl.json << EOF
{
  "signing": {
    "default": {
      "expiry": "87600h",
      "usages": [
        "signing",
        "key encipherment",
        "server auth",
        "client auth"
      ]
    }
  }
}
EOF

INSTANCE_IP="$(/sbin/ifconfig eth1 | grep 'inet addr:' | awk '{print substr($2,6)}')"

# Generate a certificate for the Nomad server
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
    -hostname="server.global.nomad,localhost,127.0.0.1,$INSTANCE_IP" - | cfssljson -bare server

# Generate a certificate for the Nomad client
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
    -hostname="client.global.nomad,localhost,127.0.0.1,$INSTANCE_IP" - | cfssljson -bare client

# Generate a certificate for the CLI
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -profile=client \
    - | cfssljson -bare cli

mkdir -p /usr/local/share/ca-certificates/extra
cp nomad-ca.pem /usr/local/share/ca-certificates/extra/nomad-ca.crt
sudo update-ca-certificates
