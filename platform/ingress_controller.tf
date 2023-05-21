
resource "helm_release" "ingress_controller" {
  count                 = var.ingress.enabled ? 1 : 0
  name                  = "nginx-ingress-controller"
  repository            = "https://kubernetes.github.io/ingress-nginx"
  chart                 = "ingress-nginx"
  version               = var.ingress.chart_version
  render_subchart_notes = false
  namespace             = var.ingress.namespace
  create_namespace      = true
  values                = [file("${path.module}/ingress-values.yml")]
  timeout               = var.ingress.timeout

  # set {
  #   name  = "controller.extraArgs.default-ssl-certificate"
  #   value = "${var.ingress.namespace}/${var.public_dns_zone}"
  # }
  set {
    name  = "controller.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "*.${var.public_dns_zone}"
  }
  set {
    name  = "controller.service.loadBalancerSourceRanges"
    value = "{${join(",", var.allowed_clients_cidrs)}}"
  }
  set {
    name  = "controller.ingressClass"
    value = "nginx"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-proxy-protocol"
    value = "*"
  }
  set {
    name  = "controller.config.use-forwarded-headers"
    value = true
  }
  set {
    name  = "controller.config.use-proxy-protocol"
    value = true
  }
  set {
    name  = "controller.config.compute-full-forwarded-for"
    value = true
  }
}


