#!/bin/bash

CONSUL_TEMPLATE_VERSION=0.22.0
CONSUL_TEMPLATE_ARCH=linux_amd64

echo "Getting consul-template binary"
wget -q https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_${CONSUL_TEMPLATE_ARCH}.zip -O /tmp/consul-template_${CONSUL_TEMPLATE_VERSION}_${CONSUL_TEMPLATE_ARCH}.zip
cd /tmp
unzip -o /tmp/consul-template_${CONSUL_TEMPLATE_VERSION}_${CONSUL_TEMPLATE_ARCH}.zip
mv consul-template /usr/local/bin/consul-template

mkdir -p /var/log/consul-template
mkdir -p /etc/consul-template

cp /vagrant/consul-templates/*.conf /etc/supervisor/conf.d/

supervisorctl reread
#supervisorctl update consul-template-haproxy
#supervisorctl start consul-template-haproxy


#don't apply  consul-template-vault till a vault token is generated for nomad
supervisorctl update consul-template-vault
#supervisorctl start consul-template-vault
