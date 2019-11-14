client {
  enabled = true
  options {
    "docker.cleanup.image"   = "0"
    "driver.raw_exec.enable" = "1"
  }
  #network_interface = "lo"
  network_interface = "eth1"
}
# Require TLS
tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad/nomad-ca.pem"
  cert_file = "/etc/nomad/client/client.pem"
  key_file  = "/etc/nomad/client/client-key.pem"

  verify_server_hostname = true
  #verify_https_client    = true
}
data_dir = "/opt/nomad/data/client"

#consul {
#  address = "127.0.0.1:8500"
#}

vault { #client dont need vault token
  enabled = true
  address = "http://active.vault.service.consul:8200"
}
