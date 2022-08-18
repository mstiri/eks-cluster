data "aws_route53_zone" "selected" {
  name         = var.public_dns_zone
  private_zone = false
}
