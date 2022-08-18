
resource "helm_release" "certs" {
  name                  = "certs"
  repository            = dirname("${path.module}/certs")
  chart                 = "certs"
  version               = "0.1.0"
  render_subchart_notes = false
  namespace             = var.cert-manager.namespace
  create_namespace      = true

  set {
    name  = "acme.email"
    value = var.acme_email
  }
  set {
    name  = "route53.dnsZone"
    value = var.public_dns_zone
  }
  set {
    name  = "route53.zoneID"
    value = data.aws_route53_zone.selected.zone_id
  }
  set {
    name  = "aws.region"
    value = var.region
  }
  set {
    name  = "aws.iamRole"
    value = module.iam_assumable_role_for_cert_manager.iam_role_arn
  }
  depends_on = [
    helm_release.cert_manager
  ]
}


