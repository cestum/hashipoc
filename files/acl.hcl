path "secret/data/*" {
  capabilities = ["create"]
}

path "secret/data/password" {
  capabilities = ["read"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

