#!/bin/bash

#Set DEBIAN_FRONTEND as noninteractive. This is required to avoid the error
# dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

apt-get update

echo "Installing unzip and jq"
apt-get install -y -q unzip jq

echo "Installing supervisor"
apt-get install -y -q supervisor
apt-get install -y virtualenv python-pip
# pip install --upgrade pip
echo "Installing supervisord-dependent-startup plugin"
pip install supervisord-dependent-startup


rm /lib/systemd/system/supervisor.service
cat << EOF > /lib/systemd/system/supervisor.service
[Unit]
Description=Supervisor process control system for UNIX
Documentation=http://supervisord.org
After=network.target

[Service]
EnvironmentFile=/etc/environment
ExecStart=/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
ExecStop=/usr/bin/supervisorctl $OPTIONS shutdown
ExecReload=/usr/bin/supervisorctl -c /etc/supervisor/supervisord.conf $OPTIONS reload
KillMode=process
Restart=on-failure
RestartSec=50s

[Install]
WantedBy=multi-user.target
EOF

cat << EOF >> /etc/supervisor/supervisord.conf

[eventlistener:dependentstartup]
command=python -m supervisord_dependent_startup
autostart=true
autorestart=unexpected
startretries=0
exitcodes=0,3
events=PROCESS_STATE

EOF

systemctl daemon-reload
