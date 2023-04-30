terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
    uri = var.libvirt_uri

}

resource "libvirt_domain" "terraform_test" {
  name = "terraform_test"
}