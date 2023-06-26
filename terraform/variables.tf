variable "proxmox_config" {
  type      = map(any)
  sensitive = true
  default = {
    api_url  = "https://proxmox-server01.example.com:8006/api2/json"
    ip       = "192.168.1.1"
    user     = "root@localhost"
    ssh_user = "root"
    password = "password"
  }
}

variable "pfsense" {
  type = map(string)
  default = {
    "version"  = "2.5.2"
    "checksum" = "941a68c7f20c4b635447cceda429a027f816bdb78d54b8252bb87abf1fc22ee3"
  }
}

variable "talos" {
  type = any
  default = {
    "version"      = "v1.4.4"
    "worker_count" = 2
    "master_ip" = "192.168.1.1"
    "worker_ip" = ["192.168.1.2", "192.168.1.3", "192.168.1.4"]
  }
}
