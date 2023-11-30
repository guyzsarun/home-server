variable "k8s_addons" {
  type = object({
    istio_version     = string
    kong_version      = string
    elk_version       = string
    kube-prom_version = string
  })

  default = {
    "istio_version"     = "1.19.3"
    "kong_version"      = "2.29.0"
    "elk_version"       = "2.9.0"
    "kube-prom_version" = "48.3.1"
  }
}