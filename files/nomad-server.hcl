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