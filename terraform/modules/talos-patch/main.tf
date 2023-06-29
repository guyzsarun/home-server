resource "null_resource" "talos_kubernetes_setup" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "talosctl gen config talos-k8s-cluster https://${var.talos.master_ip}:6443 --output-dir _talos --force"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "talosctl apply-config --insecure --nodes ${var.talos.master_ip} --file _talos/controlplane.yaml"
  }

  provisioner "local-exec" {
    environment = {
      WORKER_NODE_IP = join(" ", var.talos.worker_ip)
    }
    interpreter = ["/bin/bash", "-c"]
    command     = "for item in $WORKER_NODE_IP; do talosctl apply-config --insecure --nodes $item --file _talos/worker.yaml; done"
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOF
            rm -rf _talos/controlplane.yaml
            rm -rf _talos/worker.yaml
            rm -rf _talos/talosconfig
        EOF
  }
}


resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 200s"
  }
  triggers = {
    "before" = null_resource.talos_kubernetes_setup.id
  }
}

resource "null_resource" "talos_kubeconfig" {
  depends_on = [null_resource.delay]
  provisioner "local-exec" {
    environment = {
      TALOSCONFIG = "_talos/talosconfig"
    }
    command = <<-EOF
        talosctl config endpoint ${var.talos.master_ip}
        talosctl config node ${var.talos.master_ip}
        talosctl bootstrap
        talosctl kubeconfig _talos
        EOF
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOF
        rm -rf _talos/kubeconfig
        EOF
  }
  provisioner "local-exec" {
    environment = {
      NODE_IP = join(" ", concat(var.talos.worker_ip, [var.talos.master_ip]))
    }
    interpreter = ["/bin/bash", "-c"]
    command     = "for item in $NODE_IP; do talosctl --talosconfig _talos/talosconfig -n $item patch machineconfig --patch-file ./_talos/kubelet-patch.yaml; done"
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "talosctl --talosconfig _talos/talosconfig -n ${var.talos.master_ip} patch machineconfig --patch '[{'op': 'replace', 'path': '/machine/network/hostname', 'value': 'talos-control-plane'}]'"
  }
}