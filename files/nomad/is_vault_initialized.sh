#!/usr/bin/env bash
set -e
set -o pipefail
CONSUL_ADDRESS=${1:-"127.0.0.1:8500"}
function waitForVaultToBeAvailable() {
  local consul_addr=$1
  local isvaultkeyavailable
  isvaultkeyavailable=$(curl --silent --output /dev/null --write-out "%{http_code}" "${consul_addr}/v1/kv/service/vault/vault_token_for_nomad") || isvaultkeyavailable=""
  echo "Got result...$isvaultkeyavailable"
  while [ "x${isvaultkeyavailable}" != "x200" ] ; do
    echo "Waiting for vault token be available...$isvaultkeyavailable, $1"
    sleep 10
    isvaultkeyavailable=$(curl --silent --output /dev/null --write-out "%{http_code}" "${consul_addr}/v1/kv/service/vault/vault_token_for_nomad") || isvaultkeyavailable=""
  done
}
waitForVaultToBeAvailable "${CONSUL_ADDRESS}"