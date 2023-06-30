

### EKS Cluster creation
module "eks" {
  source                                       = "terraform-aws-modules/eks/aws"
  version                                      = "~> 19.0"
  cluster_version                              = var.cluster_version
  cluster_name                                 = local.cluster_name
  vpc_id                                       = module.vpc.vpc_id
  subnet_ids                                   = module.vpc.private_subnets
  cluster_endpoint_public_access               = true
  cluster_endpoint_private_access              = true
  cluster_endpoint_public_access_cidrs         = var.kubeapi_allowed_cidrs
  enable_irsa                                  = true
  node_security_group_enable_recommended_rules = true

  create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  tags = local.tags

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 10
    instance_types = ["t3a.small", "t3.small", "t3a.medium", "t3.medium", "t2.medium"]
    capacity_type  = "SPOT"
    update_config = {
      max_unavailable_percentage = 50
    }
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {

  }

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      labels = {
        workload_type = "default"
      }

    }
    system = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      labels = {
        workload_type = "system"
      }
      taints = [
        {
          key    = "workload_type"
          value  = "system"
          effect = "NO_SCHEDULE"
        }
      ]

    }
  }
}

