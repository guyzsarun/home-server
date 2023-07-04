terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

resource "proxmox_vm_qemu" "pfsense_vm" {
  # Clone and metadata config
  name        = "pfsense-router"
  target_node = "pve"
  clone       = "pfsense-${var.pfsense.version}-template"
  full_clone  = false


  boot     = "dcn"
  bootdisk = "scsi0"
  onboot   = "true"
  tags     = "firewall"

  # System
  memory = 1024
  cores  = 1

  # WAN
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  # LAN
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }

  define_connection_info = false

  lifecycle {
    ignore_changes = [
      full_clone,
      define_connection_info,
      disk,
    ]
  }
}


resource "proxmox_vm_qemu" "ubuntu-server_vm" {
  # Clone and metadata config
  name        = "ubuntu-server"
  target_node = "pve"
  os_type     = "ubuntu"
  clone       = "ubuntu-server-docker"
  full_clone  = true

  bootdisk = "scsi0"
  onboot   = "true"
  tags     = "jumphost"

  agent = 1

  # System
  memory = 2048
  cores  = 2

  # LAN
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }


  lifecycle {
    ignore_changes = [
      full_clone,
      disk,
    ]
  }

  ipconfig0 = "ip=dhcp"
}