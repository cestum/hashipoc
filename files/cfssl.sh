#!/bin/bash

set -e

export GOPATH=/usr/local/cfssl
PATH=$PATH:/$GOPATH/bin

/usr/local/go/bin/go get -v -u github.com/cloudflare/cfssl/cmd/...

# See https://www.nomadproject.io/guides/security/securing-nomad.html
mkdir -p /tmp/nomad-pki
cd /tmp/nomad-pki
cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare nomad-ca

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

# Generate a certificate for the Nomad server
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
    -hostname="server.global.nomad,localhost,127.0.0.1" - | cfssljson -bare server

# Generate a certificate for the Nomad client
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
    -hostname="client.global.nomad,localhost,127.0.0.1" - | cfssljson -bare client

# Generate a certificate for the CLI
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -profile=client \
    - | cfssljson -bare cli

mkdir -p /usr/local/share/ca-certificates/extra
cp nomad-ca.pem /usr/local/share/ca-certificates/extra/nomad-ca.crt
sudo update-ca-certificates