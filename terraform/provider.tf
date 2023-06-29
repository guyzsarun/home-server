terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

  }
}

provider "proxmox" {
  pm_api_url  = var.proxmox_config.api_url
  pm_user     = var.proxmox_config.user
  pm_password = var.proxmox_config.password
}

provider "kubernetes" {
  config_path = var.kubeconfig
}
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}


provider "kubectl" {
  config_path = var.kubeconfig
}