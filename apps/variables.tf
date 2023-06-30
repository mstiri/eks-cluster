
variable "public_dns_zone" {}

variable "podinfo" {
  default = {
    enabled       = true
    namespace     = "dev"
    chart_version = "6.0.3"
  }
}
