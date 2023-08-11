variable "nfs_k8s_storage" {
  type = object({
    nfs_server  = string
    nfs_path = string
  })

  default = {
    "nfs_server"  = "127.0.0.1"
    "nfs_path" = "/home/devops/nfs_share"
  }
}