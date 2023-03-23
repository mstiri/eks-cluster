
module "iam_assumable_role_for_kube_cert_acm" {
  count                         = var.kube-cert-acm.enabled ? 1 : 0
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.11.0"
  create_role                   = true
  number_of_role_policy_arns    = 1
  role_name                     = "kube-cert-acm-role-${var.eks.cluster_name}"
  provider_url                  = replace(var.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.kube_cert_acm[count.index].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.kube-cert-acm.namespace}:${var.kube-cert-acm.service_account}"]
}

# kube-cert-acm policy
data "aws_iam_policy_document" "kube_cert_acm" {
  count                         = var.kube-cert-acm.enabled ? 1 : 0
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
  statement {
    actions = [
        "acm:ListCertificates"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
        "acm:ExportCertificate",
        "acm:DescribeCertificate",
        "acm:GetCertificate",
        "acm:UpdateCertificateOptions",
        "acm:AddTagsToCertificate",
        "acm:ImportCertificate",
        "acm:ListTagsForCertificate"
    ]
    resources = ["arn:aws:acm:${var.region}:${var.account_id}:certificate/*"]
  }
}
resource "aws_iam_policy" "kube_cert_acm" {
  count  = var.kube-cert-acm.enabled ? 1 : 0
  name   = "kube-cert-acm-policy-${var.eks.cluster_name}"
  policy = data.aws_iam_policy_document.kube_cert_acm[count.index].json
}

# kube-cert-acm Helm release
resource "helm_release" "kube_cert_acm" {
  count                 = var.kube-cert-acm.enabled ? 1 : 0
  name                  = "kube-cert-acm"
  repository            = var.kube-cert-acm.helm_repository
  chart                 = "kube-cert-acm"
  version               = var.kube-cert-acm.chart_version
  render_subchart_notes = false
  namespace             = var.kube-cert-acm.namespace
  create_namespace      = true
  values                = [file("${path.module}/kube-cert-acm-values.yml")]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_for_kube_cert_acm[count.index].iam_role_arn
  }

  set {
    name = "aws.region"
    value = var.region
  }
}
