variable "vpc_cidr" {}

variable "environment" {}

variable "region" {}

variable "cluster_version" {
  description = "Kubernetes cluster version"
  default     = "1.27"
}

variable "kubeapi_allowed_cidrs" {}

variable "allowed_clients_cidrs" {}

variable "public_dns_zone" {}

variable "acme_email" {
  description = "Email to be used with the CertManager ClusterIssuer to issue certificates"
}

variable "platform" {
  description = "Flag to enable / disable the install of platform components"
  default = {
    enabled = false
  }
}

variable "apps" {
  description = "Flag to enable / disable the install of app components"
  default = {
    enabled = false
  }
}
