variable "allowed_clients_cidrs" {}

variable "public_dns_zone" {}

variable "eks" {}

variable "region" {}

variable "account_id" {}

variable "cert-manager" {
  default = {
    enabled               = false
    create_cluster_issuer = false
    chart_version         = "1.11.0"
    namespace             = "system"
    service_account       = "cert-manager"
  }
  validation {
    condition = var.cert-manager.enabled || (!var.cert-manager.enabled && !var.cert-manager.create_cluster_issuer)
    error_message = "To create the cluster issuer, the cert-manager must be enabled"
  }
}

variable "kube-cert-acm" {
  default = {
    enabled         = false
    chart_version   = "0.0.3"
    namespace       = "system"
    service_account = "kube-cert-acm"
    helm_repository = "https://mstiri.github.io/kube-cert-acm"
  }
}

variable "external-dns" {
  default = {
    enabled         = true
    chart_version   = "6.14.1"
    namespace       = "system"
    service_account = "external-dns"
  }
}

variable "ingress" {
  default = {
    enabled       = true
    namespace     = "system"
    chart_version = "4.5.2"
    timeout       = "600"
  }
}

variable "acme_email" {}
