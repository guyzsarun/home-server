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
  version    = var.k8s_addons.kong_version

  namespace = kubernetes_namespace.kong-gateway.metadata[0].name
  values = [
    "${file("../kubernetes/kong/kong-values.yaml")}"
  ]
}

resource "helm_release" "elastic-operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = var.k8s_addons.elk_version

  namespace = kubernetes_namespace.istio-system.metadata[0].name
}

resource "helm_release" "kube-prom-stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.k8s_addons.kube-prom_version

  namespace = kubernetes_namespace.istio-system.metadata[0].name
  values = [
    "${file("../kubernetes/monitoring/kube-prom-values.yaml")}"
  ]
}

resource "helm_release" "istio-base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = var.k8s_addons.istio_version

  namespace = kubernetes_namespace.istio-system.metadata[0].name
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = var.k8s_addons.istio_version

  namespace = kubernetes_namespace.istio-system.metadata[0].name

  values = [
    "${file("../kubernetes/istio/istiod-values.yaml")}"
  ]

  depends_on = [helm_release.istio-base]
}

resource "helm_release" "istio-gateway" {
  name       = "istio-gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = var.k8s_addons.istio_version

  namespace = kubernetes_namespace.istio-system.metadata[0].name

  depends_on = [helm_release.istiod]
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

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "6.6.0"

  namespace = kubernetes_namespace.argocd.metadata[0].name

  values = [
    "${file("../kubernetes/argocd/argo-values.yaml")}"
  ]
}