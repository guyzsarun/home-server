terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

resource "null_resource" "talos_base_image" {

  provisioner "remote-exec" {
    inline = [
      "cd /var/lib/vz/template/iso",
      "wget -O talos-kubernetes-${var.talos.version}.iso https://github.com/siderolabs/talos/releases/download/${var.talos.version}/metal-amd64.iso",
    ]
    connection {
      type     = "ssh"
      user     = var.proxmox_config.ssh_user
      password = var.proxmox_config.password
      host     = var.proxmox_config.ip
    }
  }
}

resource "proxmox_vm_qemu" "kubernetes-master_vm" {
  # Clone and metadata config
  count       = var.talos.master_count
  name        = "kubernetes-master-${count.index + 1}"
  vmid        = count.index + 300
  target_node = "pve"
  qemu_os     = "other"

  onboot = true
  tags   = "kubernetes;master"

  iso = "local:iso/talos-kubernetes-${var.talos.version}.iso"

  # System
  memory = 3072
  cores  = 2
  cpu    = "host"
  scsihw = "virtio-scsi-single"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 10
          storage = "local-lvm"
        }
      }
    }
  }

  # LAN
  network {
    model    = "virtio"
    bridge   = "vmbr1"
    firewall = false
  }

  depends_on = [
    null_resource.talos_base_image
  ]
}

resource "proxmox_vm_qemu" "kubernetes-worker_vm" {
  # Clone and metadata config
  count   = var.talos.worker_count
  name    = "kubernetes-worker-${count.index + 1}"
  vmid    = count.index + 400
  qemu_os = "other"

  target_node = "pve"
  onboot      = true
  tags        = "kubernetes;worker"

  iso = "local:iso/talos-kubernetes-${var.talos.version}.iso"

  # System
  memory = 9216
  cores  = 2
  cpu    = "host"
  scsihw = "virtio-scsi-single"

  # LAN
  network {
    model    = "virtio"
    bridge   = "vmbr1"
    firewall = false
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 10
          storage = "local-lvm"
        }
      }
    }
  }

  depends_on = [
    proxmox_vm_qemu.kubernetes-master_vm,
    null_resource.talos_base_image
  ]
}