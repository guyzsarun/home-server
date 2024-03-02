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
  }
}

resource "null_resource" "packer_ubuntu_template" {

  provisioner "local-exec" {
    environment = {
      PKR_VAR_proxmox_api_url  = "${var.proxmox_config.api_url}"
      PKR_VAR_proxmox_user     = "${var.proxmox_config.user}"
      PKR_VAR_proxmox_password = "${var.proxmox_config.password}"
    }
    command = "cd ${path.cwd}/packer && packer build -only '*ubuntu*' ."
  }
}

