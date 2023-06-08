resource "null_resource" "talos_kubernetes_setup" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "talosctl gen config talos-vbox-cluster https://${var.talos_master_ip}:6443 --output-dir _talos --force"
    }

    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "talosctl apply-config --insecure --nodes ${var.talos_master_ip} --file _talos/controlplane.yaml"
    }

    provisioner "local-exec" {
        environment = {
            WORKER_NODE_IP=join (" ",var.talos_worker_ip)
        }
        interpreter = ["/bin/bash", "-c"]
        command = "for item in $WORKER_NODE_IP; do talosctl apply-config --insecure --nodes $item --file _talos/worker.yaml; done"
    }
}


resource "null_resource" "talos_kubeconfig" {
    depends_on = [ null_resource.talos_kubernetes_setup ]
    provisioner "local-exec" {
         environment = {
            TALOSCONFIG="_talos/talosconfig"
        }
        command = <<-EOF
        talosctl config endpoint ${var.talos_master_ip}
        talosctl config node ${var.talos_master_ip}
        talosctl config endpoint ${var.talos_master_ip}
        talosctl config node ${var.talos_master_ip}
        talosctl bootstrap
        talosctl kubeconfig _talos
        EOF
    }
      provisioner "local-exec" {
        environment = {
            NODE_IP=join (" ",concat(var.talos_worker_ip,[var.talos_master_ip]))
        }
        interpreter = ["/bin/bash", "-c"]
        command = "for item in $NODE_IP; do talosctl --talosconfig _talos/talosconfig -n $item patch machineconfig --patch-file ./_talos/kubelet-patch.yaml; done"
    }
}

