#!/bin/bash

CONSUL_VERSION=1.6.1
CONSUL_ARCH=linux_amd64

echo "CNI plugin"
curl -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.3/cni-plugins-linux-amd64-v0.8.3.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

echo "Getting consul binary"

wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_${CONSUL_ARCH}.zip -O /tmp/consul_${CONSUL_VERSION}_${CONSUL_ARCH}.zip
cd /tmp
unzip -o /tmp/consul_${CONSUL_VERSION}_${CONSUL_ARCH}.zip
mv consul /usr/local/bin/consul

mkdir -p /var/log/consul
mkdir -p /etc/consul
mkdir -p /var/consul

#consul config
cat << EOF > /etc/consul/config.json
{
  "server": true,
  "bootstrap_expect": 3,
  "leave_on_terminate": true,
  "advertise_addr": "$(/sbin/ifconfig eth1 | grep 'inet addr:' | awk '{print substr($2,6)}')",
  "retry_join": ["192.168.50.150","192.168.50.151","192.168.50.152"],
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "bind_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "ports": {
    "grpc": 8502
  },
  "connect": {
     "enabled": true
  }
}
EOF

#supervisor config
cp /vagrant/consul/supervisor.consul.conf /etc/supervisor/conf.d/consul.conf

supervisorctl reread
supervisorctl update consul
