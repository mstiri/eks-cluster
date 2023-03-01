variable "vpc_cidr" {}

variable "environment" {}

variable "region" {}

variable "cluster_version" {}

variable "kubeapi_allowed_cidrs" {}

variable "allowed_clients_cidrs" {}

variable "public_dns_zone" {}

variable "acme_email" {
  description = "Email to be used with the CertManager ClusterIssuer to issue certificates"
}

variable "kube-cert-acm" {
  default = {
    enabled         = true
    chart_version   = "0.0.1"
    namespace       = "system"
    service_account = "kube-cert-acm"
  }
}
