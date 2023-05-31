
variable "public_dns_zone" {}

variable "podinfo" {
  default = {
    namespace     = "dev"
    chart_version = "6.0.3"
  }
}
