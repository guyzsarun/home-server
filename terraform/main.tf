module "talos-k8s" {
  source = "./modules/talos-k8s"

  talos          = var.talos
  proxmox_config = var.proxmox_config

}

module "kubernetes" {
  source = "./modules/kubernetes"

  talos          = var.talos
  depends_on = [ module.talos-k8s ]

}

module "vm-templates" {
  source = "./modules/vm-templates"

  pfsense        = var.pfsense
  proxmox_config = var.proxmox_config
}

module "vm" {
  source = "./modules/vm"

  pfsense        = var.pfsense
  proxmox_config = var.proxmox_config

  depends_on = [module.vm-templates]
}