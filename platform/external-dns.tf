
module "iam_assumable_role_for_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.14.3"
  create_role                   = true
  number_of_role_policy_arns    = 1
  role_name                     = "external-dns-role-${var.eks.cluster_name}"
  provider_url                  = replace(var.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.external-dns.namespace}:${var.external-dns.service_account}"]
}

# ExternalDNS policy
data "aws_iam_policy_document" "external_dns" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.selected.zone_id}",
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name   = "external-dns-policy-${var.eks.cluster_name}"
  policy = data.aws_iam_policy_document.external_dns.json
}

# ExternalDNS Helm release
resource "helm_release" "external_dns" {
  name                  = "external-dns"
  repository            = "https://charts.bitnami.com/bitnami"
  chart                 = "external-dns"
  version               = var.external-dns.chart_version
  values                = [file("${path.module}/external-dns-values.yml")]
  render_subchart_notes = false
  namespace             = var.external-dns.namespace
  create_namespace      = true
  set {
    name  = "serviceAccount.name"
    value = var.external-dns.service_account
  }
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "aws.region"
    value = var.region
  }
  set {
    name  = "aws.assumeRoleArn"
    value = module.iam_assumable_role_for_external_dns.iam_role_arn
  }
  set {
    name  = "aws.zoneType"
    value = "public"
  }
  set {
    name  = "domainFilters[0]"
    value = data.aws_route53_zone.selected.name
  }
  set {
    name  = "zoneIdFilters[0]"
    value = data.aws_route53_zone.selected.zone_id
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_for_external_dns.iam_role_arn
  }
}

