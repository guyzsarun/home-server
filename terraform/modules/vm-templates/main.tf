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

resource "null_resource" "pfsense_base_image" {
  provisioner "remote-exec" {
    inline = [
      "cd /var/lib/vz/template/iso",
      "wget https://sgpfiles.netgate.com/mirror/downloads/pfSense-CE-'${var.pfsense.version}'-RELEASE-amd64.iso.gz",
      "gunzip -c pfSense-CE-'${var.pfsense.version}'-RELEASE-amd64.iso.gz > pfSense-'${var.pfsense.version}'-amd64.iso",
      "rm pfSense-CE-'${var.pfsense.version}'-RELEASE-amd64.iso.gz"
    ]
    connection {
      type     = "ssh"
      user     = var.proxmox_config.ssh_user
      password = var.proxmox_config.password
      host     = var.proxmox_config.ip
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "packer_pfsense_template" {

  provisioner "local-exec" {
    environment = {
      PKR_VAR_proxmox_api_url  = "${var.proxmox_config.api_url}"
      PKR_VAR_proxmox_user     = "${var.proxmox_config.user}"
      PKR_VAR_proxmox_password = "${var.proxmox_config.password}"

      PKR_VAR_pfsense_path     = "local:iso/pfSense-${var.pfsense.version}-amd64.iso"
      PKR_VAR_pfsense_checksum = "${var.pfsense.checksum}"
      PKR_VAR_pfsense_version  = "${var.pfsense.version}"
    }
    command = "cd ${path.cwd}/packer && packer build -only '*pfsense*' ."
  }

  depends_on = [
    null_resource.pfsense_base_image
  ]
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

