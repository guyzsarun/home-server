variable "proxmox_config" {
  type = object({
    api_url  = string
    ip       = string
    user     = string
    ssh_user = string
    password = string
  })
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
    "master_count" = 1
    "worker_count" = 2
  }
}
