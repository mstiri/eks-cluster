### Data sources ###
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

### Kubernetes provider configuration
data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

### Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

#### Platform module
module "platform" {
  count                 = var.platform.enabled ? 1 : 0
  source                = "./platform"
  allowed_clients_cidrs = var.allowed_clients_cidrs
  public_dns_zone       = var.public_dns_zone
  eks                   = module.eks
  region                = var.region
  acme_email            = var.acme_email
  account_id            = local.account_id
}

#### Apps module
module "apps" {
  count           = var.apps.enabled ? 1 : 0
  source          = "./apps"
  public_dns_zone = var.public_dns_zone
  depends_on = [
    module.platform
  ]
}

