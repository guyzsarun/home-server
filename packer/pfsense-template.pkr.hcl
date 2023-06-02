source "proxmox-iso" "pfsense-template" {
    # ID
    template_name = "pfsense-${var.pfsense_version}-template"
    node = "pve"
    template_description = "pfSense router for home-server"

    # Proxmox Access configuration
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_user}"
    password = "${var.proxmox_password}"
    insecure_skip_tls_verify = true

    # Base ISO File configuration
    iso_file = "${var.pfsense_path}"
    iso_checksum = "${var.pfsense_checksum}"
    iso_storage_pool = "local"


    # System
    memory = 1024
    cores = 1

    # Storage
    disks {
        type="scsi"
        disk_size="10G"
        storage_pool="local-lvm"
        storage_pool_type="lvm"
    }

    # Network
    network_adapters {
            model = "virtio"
            bridge = "vmbr0"
    }

    # Remove installation media
    unmount_iso = true

    # Start this on system boot
    onboot = true
    scsi_controller = "virtio-scsi-pci"

    # Boot commands
    boot_wait = "30s"
    boot_command = [
        # Accept copyright
        "<enter><wait2s>",
        # Options: Install, Rescue Shell, Recover config.xml
        # Press enter to install
        "<enter><wait2s>",

        # Select keyboard layout, default US
        "<enter><wait2s>",

        # Options: Auto (UFS) Bios, Auto (UFS) UEFI, Manual, Shell, Auto (ZFS)
        # Enter for Auto UFS Bios
        "<enter><wait2s>",

        # Install
        "<enter><wait2s>",
        "<enter><wait2s>",
        "<spacebar><wait2s>",
        "<enter><wait2s>",
        "<left><wait><enter>",

        # Wait installation and reboot
        "<wait60s><enter><wait><enter>",

        "<wait90s>n<enter>",
        "<wait>vtnet0<enter><wait>",
        "<enter><wait>y<enter><wait2m>",

        # Enable ssh
        "14<enter><wait>y<enter>",

        # Install zerotier
        "<wait>8<wait><enter>",
        "pkg add https://pkg.freebsd.org/FreeBSD:12:amd64/latest/All/zerotier-1.10.6.pkg<enter><wait>y<enter><wait1m>",
        "echo zerotier_enable='YES' > /etc/rc.conf<enter><wait>",
        "pkg add https://github.com/tuxpowered/pfSense-pkg-zerotier/releases/download/0.00.1/pfSense-pkg-zerotier-0.00.1.pkg<enter><wait>y<enter><wait1m>",
        "poweroff<wait><enter>"
    ]


    communicator = "none"
}
build {
    // Load iso configuration
   sources = ["source.proxmox-iso.pfsense-template"]
}