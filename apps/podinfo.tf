
### Podinfo Helm release
resource "helm_release" "podinfo" {
  count            = var.podinfo.enabled ? 1 : 0
  name             = "podinfo"
  repository       = "https://stefanprodan.github.io/podinfo"
  chart            = "podinfo"
  version          = var.podinfo.chart_version
  namespace        = var.podinfo.namespace
  create_namespace = "true"
  values           = [file("${path.module}/podinfo-values.yml")]
  set {
    name  = "ingress.hosts[0].host"
    value = "podinfo.${var.public_dns_zone}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "podinfo.${var.public_dns_zone}"
  }
  set {
    name  = "ingress.tls[0].secretName"
    value = "podinfo.${var.public_dns_zone}"
  }
}
