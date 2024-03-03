terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

resource "proxmox_vm_qemu" "opnsense_vm" {
  # Clone and metadata config
  name        = "opnsense-router"
  target_node = "pve"
  iso         = "local:iso/OPNsense-24.1-dvd-amd64.iso"
  onboot      = true

  tags = "firewall"

  # System
  memory = 2048
  cores  = 1
  cpu    = "host"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 15
          storage = "local-lvm"
        }
      }
    }
  }

  # LAN 1
  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # LAN 2
  network {
    model    = "virtio"
    bridge   = "vmbr1"
    firewall = false
  }

  lifecycle {
    ignore_changes = [
      agent,
      disk,
      qemu_os
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
  desc        = "Ubuntu Server Bastion VM"

  onboot = "true"
  tags   = "jumphost"

  agent = 1

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 15
          storage = "local-lvm"
        }
      }
    }
  }

  # System
  memory = 4096
  cores  = 2

  # LAN
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }

  lifecycle {
    ignore_changes = [
      disk,
      qemu_os
    ]
  }

  ipconfig0 = "ip=dhcp"
}

resource "proxmox_vm_qemu" "nas_vm" {
  # Clone and metadata config
  name        = "nas-server"
  target_node = "pve"
  os_type     = "ubuntu"
  clone       = "ubuntu-server-docker"
  full_clone  = true
  desc        = "Nas Server VM"

  onboot = "true"
  tags   = "storage"

  agent = 1

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 128
          storage = "local-lvm"
        }
      }
    }
  }

  # System
  memory = 1024
  cores  = 1

  # LAN
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }

  lifecycle {
    ignore_changes = [
      disk,
      qemu_os
    ]
  }
  ipconfig0 = "ip=dhcp"
}

# resource "proxmox_vm_qemu" "home-assistant-vm" {
#   # Clone and metadata config
#   name        = "home-assistant"
#   target_node = "pve"
#   os_type     = "ubuntu"
#   clone       = "ubuntu-server-docker"
#   full_clone  = false


#   onboot = "true"
#   tags   = "home-assistant"

#   agent = 1

#   # System
#   memory = 4096
#   cores  = 1

#   # LAN
#   network {
#     model  = "virtio"
#     bridge = "vmbr1"
#   }


#   lifecycle {
#     ignore_changes = [
#       desc,
#       qemu_os,
#       full_clone,
#       disk,
#     ]
#   }

#   disk {
#     type    = "scsi"
#     storage = "local-lvm"
#     size    = "10G"
#   }

#   ipconfig0 = "ip=dhcp"
# }