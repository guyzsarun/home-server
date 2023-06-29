variable "talos" {
  type = any
  default = {
    "master_ip" = "192.168.1.1"
    "worker_ip" = ["192.168.1.2", "192.168.1.3", "192.168.1.4"]
  }
}
