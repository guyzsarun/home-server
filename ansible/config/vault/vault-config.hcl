ui            = true
log_level     = "INFO"
api_addr      = "https://0.0.0.0:8200"
disable_mlock = true

storage "file" {
    path = "/home/devops/vault/data"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/home/devops/certs/k8s.proxmox.local.crt"
  tls_key_file  = "/home/devops/certs/k8s.proxmox.local.key"
}
