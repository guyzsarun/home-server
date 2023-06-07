variable "proxmox_api_url" {
    type = string
    default = "https://proxmox-server01.example.com:8006/api2/json"
}

variable "proxmox_user" {
    type = string
    default = "root@localhost"
}

variable "proxmox_ssh_user" {
    type = string
    default = "root"
}

variable "proxmox_password"{
    type = string
    sensitive = true
    default = "password"
}

variable "proxmox_ip" {
    type = string
    default = "192.168.1.1"
    sensitive = true
}

variable "pfsense_version" {
    default = "2.5.2"
    type = string
}
variable "pfsense_checksum" {
    default = "941a68c7f20c4b635447cceda429a027f816bdb78d54b8252bb87abf1fc22ee3"
}

variable "talos_version" {
  default = "v1.4.4"
}

variable "talos_master_ip" {
    default = "192.168.1.1"
}

variable "talos_worker_ip" {
  type    = list
  default = ["192.168.1.2", "192.168.1.3", "192.168.1.4"]
}
variable "talos_worker_count" {
  default = "2"
}
