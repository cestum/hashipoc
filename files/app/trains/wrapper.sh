#!/usr/bin/env bash
set -e

mkdir -p /var/log/trains

server_type=$1

if (( $# != 1 )) ; then
    echo "The server type was not stated. It should be either apiserver, webserver or fileserver."
    sleep 60
    exit 1
elif [[ ${server_type} == "apiserver" ]]; then
    cd /opt/trains/server/
    python3 -m apierrors.autogen
    python3 server.py
elif [[ ${server_type} == "webserver" ]]; then
    /usr/sbin/nginx -g "daemon off;"
elif [[ ${server_type} == "fileserver" ]]; then
    cd /opt/trains/fileserver/
    python3 fileserver.py
else
    echo "Server type ${server_type} is invalid. Please choose either apiserver, webserver or fileserver."
fi