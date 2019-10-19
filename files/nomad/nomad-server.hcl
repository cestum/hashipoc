server {
  enabled = true
  bootstrap_expect = 1
}

# Increase log verbosity
log_level = "DEBUG"

# Require TLS
tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad/nomad-ca.pem"
  cert_file = "/etc/nomad/server.pem"
  key_file  = "/etc/nomad/server-key.pem"

  verify_server_hostname = true
# verify_https_client    = true
}
acl {
  enabled = true
  token_ttl = "30s"
  policy_ttl = "60s"
}

data_dir = "/opt/nomad/data/server"

advertise {
  http = "{{ GetInterfaceIP `eth1` }}"
  rpc  = "{{ GetInterfaceIP `eth1` }}"
  serf = "{{ GetInterfaceIP `eth1` }}" 
}
consul {
  address = "127.0.0.1:8500"
}
