terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb-system"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}


resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.10"

  namespace = kubernetes_namespace.metallb.metadata[0].name

  set {
    name  = "speaker.frr.enabled"
    value = "false"
  }
  provisioner "local-exec" {
    command = "echo 'Waiting CRDs' && sleep 60"
  }
  depends_on = [kubernetes_namespace.metallb]
}

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "kube-prom-stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "48.3.1"

  namespace = "istio-system"
  values = [
    "${file("../kubernetes/monitoring/kube-prom-values.yaml")}"
  ]

  depends_on = [
    kubernetes_namespace.istio-system,
    helm_release.nfs-storage
    ]
}

resource "helm_release" "nfs-storage" {
  name       = "nfs-provisioner"
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"
  chart      = "nfs-subdir-external-provisioner"
  version    = "4.0.18"

  namespace = "kube-system"

  set {
    name  = "nfs.server"
    value = var.nfs_k8s_storage.nfs_server
  }

  set {
    name  = "nfs.path"
    value = var.nfs_k8s_storage.nfs_path
  }

  set {
    name  = "storageClass.defaultClass"
    value = "true"
  }

}

resource "kubectl_manifest" "metallb-pool" {
  override_namespace = kubernetes_namespace.metallb.metadata[0].name
  yaml_body          = <<YAML
  apiVersion: "metallb.io/v1beta1"
  kind: IPAddressPool
  metadata:
    name: metallb-pool
  spec:
    addresses: ["192.168.101.1-192.168.101.50"]
  YAML
  depends_on         = [helm_release.metallb]
}

resource "kubectl_manifest" "metallb-l2-advertisement" {
  override_namespace = kubernetes_namespace.metallb.metadata[0].name
  yaml_body          = <<YAML
  apiVersion: "metallb.io/v1beta1"
  kind: L2Advertisement
  metadata:
    name: metallb-l2-ip
  YAML
  depends_on         = [kubectl_manifest.metallb-pool, helm_release.metallb]
}

data "http" "kubelet-approver" {
  url = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
}

data "kubectl_file_documents" "metrics_server_doc" {
  content = data.http.kubelet-approver.response_body
}
resource "kubectl_manifest" "kubelet-approver" {
  for_each  = data.kubectl_file_documents.metrics_server_doc.manifests
  yaml_body = each.value

}

resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.10.0"

  namespace = "kube-system"

  depends_on = [kubectl_manifest.kubelet-approver]
}
