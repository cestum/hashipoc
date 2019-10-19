vault {
  enabled = true
  create_from_role = "nomad-cluster"
  address = "http://active.vault.service.consul:8200"
  token = "{{ key "service/vault/vault_token_for_nomad" }}"
}