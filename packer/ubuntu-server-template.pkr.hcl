source "proxmox-iso" "ubuntu-server-docker" {
    # ID
    node = "pve"
    template_name = "ubuntu-server-docker"
    template_description = "Ubuntu Server Jumphost"

    # Proxmox Access configuration
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_user}"
    password = "${var.proxmox_password}"
    insecure_skip_tls_verify = true

    # Base ISO File configuration
    iso_url = "https://releases.ubuntu.com/jammy/ubuntu-22.04.4-live-server-amd64.iso"
    iso_checksum = "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
    iso_download_pve = true
    iso_storage_pool = "local"
    unmount_iso = true

    qemu_agent = true

    # System
    cores = 2
    memory = 2048

    scsi_controller = "virtio-scsi-pci"

    # Storage
    disks {
         disk_size = "5G"
         storage_pool = "local-lvm"
         type = "scsi"
    }

    # VM Network Settings
    network_adapters {
         bridge = "vmbr1"
         firewall = "false"
         model = "virtio"
    }

    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    boot_command =  [
      "c",
      "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
      "<enter><wait>",
      "initrd /casper/initrd<enter><wait>",
      "boot<enter>"
    ]

    boot = "c"
    boot_wait = "10s"

    http_directory = "http"

    ssh_username= "devops"
    ssh_password = "password"

    ssh_timeout = "10m"
}

# Build Definition to create the VM Template
build {

    sources = ["source.proxmox-iso.ubuntu-server-docker"]

    provisioner "shell" {
         inline = [
             "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
             "sudo rm /etc/ssh/ssh_host_*",
             "sudo truncate -s 0 /etc/machine-id",
             "sudo apt -y autoremove --purge",
             "sudo apt -y clean",
             "sudo apt -y autoclean",
             "sudo cloud-init clean",
             "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
             "sudo sync"
         ]
    }

     provisioner "file" {
         source = "files/99-pve.cfg"
         destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
         inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io qemu-guest-agent"
        ]
    }

}