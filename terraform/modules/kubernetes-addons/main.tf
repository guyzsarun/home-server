terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

resource "kubernetes_namespace" "kong-gateway" {
  metadata {
    name = "kong-gateway"
    labels = {
      "istio-injection"                    = "enabled"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "kong-gateway" {
  name       = "kong-gateway"
  repository = "https://charts.konghq.com"
  chart      = "kong"
  version    = "2.29.0"

  namespace = kubernetes_namespace.kong-gateway.metadata[0].name
  values = [
    "${file("../kubernetes/kong/kong-values.yaml")}"
  ]
}

resource "helm_release" "elastic-operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = "2.9.0"

  namespace = kubernetes_namespace.istio-system.metadata[0].name
}

data "kubectl_path_documents" "elk" {
    pattern = "../kubernetes/elk/*.yaml"
}

resource "kubectl_manifest" "elk-kibana" {
    for_each  = toset(data.kubectl_path_documents.elk.documents)
    yaml_body = each.value
    override_namespace = kubernetes_namespace.istio-system.metadata[0].name
}

resource "helm_release" "kube-prom-stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "48.3.1"

  namespace = kubernetes_namespace.istio-system.metadata[0].name
  values = [
    "${file("../kubernetes/monitoring/kube-prom-values.yaml")}"
  ]

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