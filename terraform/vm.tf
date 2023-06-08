resource "proxmox_vm_qemu" "pfsense_vm" {
    # Clone and metadata config
    name = "pfsense-router"
    target_node = "pve"
    clone = "pfsense-${var.pfsense_version}-template"
    full_clone = false


    boot = "dcn"
    bootdisk = "scsi0"
    onboot = "true"
    tags = "firewall"

    # System
    memory = 1024
    cores = 1

    # WAN
    network {
      model = "virtio"
      bridge = "vmbr0"
     }
    # LAN
     network {
      model = "virtio"
      bridge = "vmbr1"
     }

    define_connection_info = false

    depends_on = [
      null_resource.packer_pfsense_template,
    ]

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
    name = "ubuntu-server"
    target_node = "pve"
    os_type = "ubuntu"
    clone = "ubuntu-server-docker"
    full_clone = true

    bootdisk = "scsi0"
    onboot = "true"
    tags = "jumphost"

    agent = 1

    # System
    memory = 2048
    cores = 2

    # LAN
     network {
      model = "virtio"
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
resource "proxmox_vm_qemu" "kubernetes-master_vm" {
    # Clone and metadata config
    name  = "kubernetes-master"
    vmid   = 301
    target_node = "pve"
    qemu_os = "other"

    onboot = true
    tags = "kubernetes"

    iso = "local:iso/talos-kubernetes-${var.talos_version}.iso"

    # System
    memory = 4096
    cores = 2
    cpu = "host"
    scsihw = "virtio-scsi-single"

    disk {
      type = "scsi"
      size = "10G"
      storage = "local-lvm"
    }

    # LAN
    network {
      model = "virtio"
      bridge = "vmbr1"
      firewall = false
     }

    depends_on = [
      null_resource.talos_base_image,
    ]
}

resource "proxmox_vm_qemu" "kubernetes-worker_vm" {
    # Clone and metadata config
    count = "${var.talos_worker_count}"
    name  = "kubernetes-worker-${count.index + 1}"
    vmid   = "${count.index + 302}"
    qemu_os = "other"

    target_node = "pve"
    onboot = true
    tags = "kubernetes"

    iso = "local:iso/talos-kubernetes-${var.talos_version}.iso"

    # System
    memory = 2048
    cores = 2
    cpu = "host"
    scsihw = "virtio-scsi-single"

    # LAN
     network {
      model = "virtio"
      bridge = "vmbr1"
      firewall = false
     }

    disk {
      type = "scsi"
      size = "5G"
      storage = "local-lvm"
    }
    depends_on = [
      proxmox_vm_qemu.kubernetes-master_vm,
    ]
}