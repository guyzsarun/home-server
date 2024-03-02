module "talos-k8s" {
  source = "./modules/talos-k8s"

  talos          = var.talos
  proxmox_config = var.proxmox_config

}

module "talos-patch" {
  source = "./modules/talos-patch"

  talos      = var.talos
  depends_on = [module.talos-k8s]
}

module "kubernetes" {
  source = "./modules/kubernetes"

  nfs_k8s_storage = var.nfs_k8s_storage
  depends_on      = [module.talos-patch]
}

module "kubernetes-addons" {
  source = "./modules/kubernetes-addons"

  k8s_addons = var.k8s_addons
  depends_on = [module.kubernetes]
}

module "vm-templates" {
  source = "./modules/vm-templates"
  proxmox_config = var.proxmox_config
}

module "vm" {
  source = "./modules/vm"
  proxmox_config = var.proxmox_config

  depends_on = [module.vm-templates]
}