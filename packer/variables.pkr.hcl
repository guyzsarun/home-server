variable "proxmox_api_url" {
    type = string
    default = "https://proxmox-server01.example.com:8006/api2/json"
}

variable "proxmox_user" {
    type = string
    default = "root@localhost"
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
