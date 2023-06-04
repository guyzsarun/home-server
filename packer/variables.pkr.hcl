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

variable "pfsense_img" {
    default = "https://sgpfiles.netgate.com/mirror/downloads/pfSense-CE-2.6.0-RELEASE-amd64.iso.gz"
}

variable "pfsense_version"{
    default = "2.5.2"
}

variable "pfsense_checksum" {
    default = "941a68c7f20c4b635447cceda429a027f816bdb78d54b8252bb87abf1fc22ee3"
}

variable "pfsense_path" {
    default = "local:iso/pfSense-2.5.2-amd64.iso"
}
