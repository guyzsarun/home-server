ui            = true
log_level     = "INFO"
api_addr      = "https://0.0.0.0:8200"
disable_mlock = true

storage "file" {
    path = "/mnt/nfs_share/vault"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable = false
  tls_cert_file = "/home/devops/certs/server.proxmox.local.pem"
  tls_key_file  = "/home/devops/certs/server.proxmox.local.key"
}
