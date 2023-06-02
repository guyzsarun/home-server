source "proxmox-iso" "ubuntu-server-docker" {
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_user}"
    password = "${var.proxmox_password}"
    insecure_skip_tls_verify = true

    node = "pve"

    vm_name = "ubuntu-server-docker"
    template_description = "Ubuntu Server Jumphost"

    iso_url = "https://releases.ubuntu.com/jammy/ubuntu-22.04.2-live-server-amd64.iso"
    iso_checksum = "5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"

    #iso_download_pve = true


    iso_storage_pool = "local"
    unmount_iso = true

    qemu_agent = true


    scsi_controller = "virtio-scsi-pci"

    disks {
         disk_size = "20G"
         storage_pool = "local-lvm"
         type = "virtio"
    }

    cores = "2"

    memory = "2048"

    # VM Network Settings
    network_adapters {
         bridge = "vmbr1"
         firewall = "false"
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
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
        ]
    }

}