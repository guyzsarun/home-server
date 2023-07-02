variable "proxmox_config" {
  type      = map(string)
  sensitive = true
  default = {
    api_url  = "https://proxmox-server01.example.com:8006/api2/json"
    ip       = "192.168.1.1"
    user     = "root@localhost"
    ssh_user = "root"
    password = "password"
  }
}

variable "talos" {
  type = any
  default = {
    "version"      = "v1.4.4"
    "worker_count" = 2
  }
}