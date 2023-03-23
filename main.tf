### Data sources ###
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  cluster_name = "${var.environment}_${var.region}_cluster"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

### Kubernetes provider configuration
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

### Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

#### Platform module
module "platform" {
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
  source          = "./apps"
  public_dns_zone = var.public_dns_zone
  depends_on = [
    module.platform
  ]
}

