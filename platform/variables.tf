variable "allowed_clients_cidrs" {}

variable "public_dns_zone" {}

variable "eks" {}

variable "region" {}

variable "cert-manager" {
  default = {
    chart_version   = "1.6.1"
    namespace       = "system"
    service_account = "cert-manager"
  }
}

variable "external-dns" {
  default = {
    chart_version   = "6.7.5"
    namespace       = "system"
    service_account = "external-dns"
  }
}

variable "ingress" {
  default = {
    namespace     = "system"
    chart_version = "4.2.1"
  }
}

variable "acme_email" {}
