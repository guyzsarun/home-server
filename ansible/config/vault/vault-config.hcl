ui            = true
log_level     = "INFO"
api_addr      = "http://0.0.0.0:8200"
disable_mlock = true

storage "file" {
    path = "/home/devops/vault/data"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = true
}
