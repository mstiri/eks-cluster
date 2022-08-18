

### EKS Cluster creation
module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "18.27.1"
  cluster_version                      = var.cluster_version
  cluster_name                         = local.cluster_name
  vpc_id                               = module.vpc.vpc_id
  subnet_ids                           = module.vpc.private_subnets
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.kubeapi_allowed_cidrs
  enable_irsa                          = true

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 10
    instance_types = ["t3a.small"]
    capacity_type  = "SPOT"
    update_config = {
      max_unavailable_percentage = 50
    }
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_ephemeral_ports = {
      description                = "Allow outgoing ephemeral port 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      labels = {
        workload_type = "default"
      }

    }
    system = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

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

