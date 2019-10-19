#!/usr/bin/env bash
set -e

# cat << EOF > /etc/systemd/system/consul-online.target
# [Unit]
# Description=Consul Online
# RefuseManualStart=true
# EOF
mkdir -p /var/log/consul-online
mkdir -p /etc/consul-online
mkdir -p /var/consul-online

cp /vagrant/consul-online/consul-online-checker.sh /usr/bin/consul-online.sh
chmod +x /usr/bin/consul-online.sh

#supervisor config
cp /vagrant/consul-online/supervisor.consul-online.conf /etc/supervisor/conf.d/consul-online.conf

supervisorctl reread
supervisorctl update consul-online


# cat << EOF > /etc/systemd/system/consul-online.service
# [Unit]
# Description=Consul Online
# Requires=consul.service
# After=consul.service
# [Service]
# Type=oneshot
# ExecStart=/usr/bin/consul-online.sh
# User=consul
# Group=consul
# [Install]
# WantedBy=consul-online.target multi-user.target
# EOF