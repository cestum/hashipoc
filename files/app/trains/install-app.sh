#!/usr/bin/env bash
set -e


echo "vm.max_map_count=262144" > /tmp/99-trains.conf
mv /tmp/99-trains.conf /etc/sysctl.d/99-trains.conf
sysctl -w vm.max_map_count=262144
service docker restart
mkdir -p /opt/trains/data/elastic
mkdir -p /opt/trains/data/mongo/db
mkdir -p /opt/trains/data/mongo/configdb
mkdir -p /opt/trains/data/redis
mkdir -p /opt/trains/logs
mkdir -p /opt/trains/data/fileserver
mkdir -p /opt/trains/config/default
chown -R 1000:1000 /opt/trains
