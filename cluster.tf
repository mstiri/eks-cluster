

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

  cluster_addons = {
    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
  }

  tags = local.tags

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3a.small", "t3.small", "t3a.medium", "t3.medium", "t2.medium"]
    capacity_type  = "SPOT"
    update_config = {
      max_unavailable_percentage = 50
    }
    # This is a workaround for the issue https://github.com/aws/containers-roadmap/issues/1666
    # Initially we should attach the policy to the nodes IAM Role to be able to
    # assign IPs and join the cluster. After the cluster and node group are created
    # This should be turned off. VPC CNI will use the IRSA defined below
    iam_role_attach_cni_policy = true
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
      desired_size = 1
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

## IRSA for VPC CNI
module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "vpc-cni-irsa-"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}
