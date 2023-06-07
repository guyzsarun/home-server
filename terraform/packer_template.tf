resource "null_resource" "pfsense_base_image" {

    lifecycle {
        prevent_destroy = true
    }

    provisioner "remote-exec" {
        inline = [
            "cd /var/lib/vz/template/iso",
            "wget https://sgpfiles.netgate.com/mirror/downloads/pfSense-CE-'${var.pfsense_version}'-RELEASE-amd64.iso.gz",
            "gunzip -c pfSense-CE-'${var.pfsense_version}'-RELEASE-amd64.iso.gz > pfSense-'${var.pfsense_version}'-amd64.iso",
            "rm pfSense-CE-'${var.pfsense_version}'-RELEASE-amd64.iso.gz"
        ]
        connection {
            type     = "ssh"
            user     = "${var.proxmox_ssh_user}"
            password = "${var.proxmox_password}"
            host     = "${var.proxmox_ip}"
        }
    }
}

resource "null_resource" "packer_pfsense_template" {

    provisioner "local-exec" {
        environment = {
            PKR_VAR_proxmox_api_url="${var.proxmox_api_url}"
            PKR_VAR_proxmox_user="${var.proxmox_user}"
            PKR_VAR_proxmox_password="${var.proxmox_password}"
            PKR_VAR_pfsense_path="local:iso/pfSense-${var.pfsense_version}-amd64.iso"
            PKR_VAR_pfsense_checksum="${var.pfsense_checksum}"
            PKR_VAR_pfsense_version="${var.pfsense_version}"
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
            PKR_VAR_proxmox_api_url="${var.proxmox_api_url}"
            PKR_VAR_proxmox_user="${var.proxmox_user}"
            PKR_VAR_proxmox_password="${var.proxmox_password}"
        }
        command = "cd ${path.cwd}/packer && packer build -only '*ubuntu*' ."
    }
}

resource "null_resource" "talos_base_image" {

    provisioner "remote-exec" {
        inline = [
            "cd /var/lib/vz/template/iso",
            "wget -O talos-kubernetes-${var.talos_version}.iso https://github.com/siderolabs/talos/releases/download/${var.talos_version}/talos-amd64.iso",
        ]
        connection {
            type     = "ssh"
            user     = "${var.proxmox_ssh_user}"
            password = "${var.proxmox_password}"
            host     = "${var.proxmox_ip}"
        }
    }
}