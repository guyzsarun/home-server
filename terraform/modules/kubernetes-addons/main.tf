resource "kubernetes_namespace" "kong-gateway" {
  metadata {
    name = "kong-gateway"
    labels = {
        "istio-injection" = "enabled"
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

  namespace = "kong-gateway"
  values = [
    "${file("../kubernetes/kong/kong-values.yaml")}"
  ]

  depends_on = [
    kubernetes_namespace.kong-gateway
    ]
}