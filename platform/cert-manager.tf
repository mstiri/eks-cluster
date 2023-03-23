
module "iam_assumable_role_for_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.14.3"
  create_role                   = true
  number_of_role_policy_arns    = 1
  role_name                     = "cert-manager-role-${var.eks.cluster_name}"
  provider_url                  = replace(var.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.cert-manager.namespace}:${var.cert-manager.service_account}"]
}

# Cert-manager policy
data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }

  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.selected.zone_id}"
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZonesByName"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "cert_manager" {
  name   = "cert-manager-policy-${var.eks.cluster_name}"
  policy = data.aws_iam_policy_document.cert_manager.json
}

# Cert-manager Helm release
resource "helm_release" "cert_manager" {
  name                  = "cert-manager"
  repository            = "https://charts.jetstack.io"
  chart                 = "cert-manager"
  version               = var.cert-manager.chart_version
  render_subchart_notes = false
  namespace             = var.cert-manager.namespace
  create_namespace      = true
  values                = [file("${path.module}/cert-manager-values.yml")]
  set {
    name  = "installCRDs"
    value = true
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_for_cert_manager.iam_role_arn
  }
}
