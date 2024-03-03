variable "proxmox_config" {
  sensitive = true
  type = object({
    api_url  = string
    ip       = string
    user     = string
    ssh_user = string
    password = string
  })
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
    "master_ip"    = "192.168.1.1"
    "worker_ip"    = ["192.168.1.2", "192.168.1.3", "192.168.1.4"]
  }
}

variable "kubeconfig" {
  type    = string
  default = "_talos/kubeconfig"
}

variable "nfs_k8s_storage" {
  type = object({
    nfs_server = string
    nfs_path   = string
  })
  default = {
    "nfs_server" = "127.0.0.1"
    "nfs_path"   = "/home/devops/nfs_share"
  }
}

variable "k8s_addons" {
  type = object({
    istio_version     = string
    kong_version      = string
    elk_version       = string
    kube-prom_version = string
  })

  default = {
    "istio_version"     = "1.19.3"
    "kong_version"      = "2.29.0"
    "elk_version"       = "2.9.0"
    "kube-prom_version" = "48.3.1"
  }
}