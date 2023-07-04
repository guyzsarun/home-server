terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

resource "null_resource" "talos_base_image" {

  provisioner "remote-exec" {
    inline = [
      "cd /var/lib/vz/template/iso",
      "wget -O talos-kubernetes-${var.talos.version}.iso https://github.com/siderolabs/talos/releases/download/${var.talos.version}/talos-amd64.iso",
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
  name        = "kubernetes-master"
  vmid        = 301
  target_node = "pve"
  qemu_os     = "other"

  onboot = true
  tags   = "kubernetes"

  iso = "local:iso/talos-kubernetes-${var.talos.version}.iso"

  # System
  memory = 8192
  cores  = 2
  cpu    = "host"
  scsihw = "virtio-scsi-single"

  disk {
    type    = "scsi"
    size    = "10G"
    storage = "local-lvm"
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
  vmid    = count.index + 302
  qemu_os = "other"

  target_node = "pve"
  onboot      = true
  tags        = "kubernetes"

  iso = "local:iso/talos-kubernetes-${var.talos.version}.iso"

  # System
  memory = 6000
  cores  = 2
  cpu    = "host"
  scsihw = "virtio-scsi-single"

  # LAN
  network {
    model    = "virtio"
    bridge   = "vmbr1"
    firewall = false
  }

  disk {
    type    = "scsi"
    size    = "10G"
    storage = "local-lvm"
  }
  depends_on = [
    proxmox_vm_qemu.kubernetes-master_vm,
    null_resource.talos_base_image
  ]
}