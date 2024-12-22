module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.prefix
  cluster_version = var.eks.version

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  enable_irsa = true

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true
      configuration_values = jsonencode({
        replicaCount = 1
        nodeSelector = {
          role = var.eks.init_node_name
        }
      })
      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      configuration_values = jsonencode({
        controller = {
          replicaCount = 1
          nodeSelector = {
            role = var.eks.init_node_name
          }
        }
      })
    }
  }

  enable_cluster_creator_admin_permissions = true

  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []

  eks_managed_node_group_defaults = {
    create_iam_role = false
    iam_role_arn    = aws_iam_role.eks_node_role.arn

    attach_cluster_primary_security_group = true
    ebs_optimized                        = true

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 40
          volume_type          = "gp3"
          iops                 = 3000
          throughput           = 150
          delete_on_termination = true
        }
      }
    }
  }

  eks_managed_node_groups = {
    base = {
      name            = "${var.prefix}-${var.eks.init_node_name}"
      use_name_prefix = false
      instance_types  = ["t3.medium"]
      capacity_type   = "ON_DEMAND"
      min_size        = var.eks.init_node_count
      max_size        = var.eks.init_node_count
      desired_size    = var.eks.init_node_count
      subnet_ids      = module.vpc.private_subnets

      labels = {
        role = var.eks.init_node_name
      }
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Allow inbound traffic on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    from_karpenter_nodes = {
      description              = "Allow inbound traffic from Karpenter nodes"
      protocol                = -1
      from_port               = 0
      to_port                 = 0
      type                    = "ingress"
      source_security_group_id = aws_security_group.eks_node.id
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Allow inbound traffic between nodes"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    allow_karpenter_nodes = {
      description              = "Allow inbound traffic from Karpenter nodes"
      protocol                = "-1"
      from_port               = 0
      to_port                 = 0
      type                    = "ingress"
      source_security_group_id = aws_security_group.eks_node.id
    }
  }

  tags = {
    Environment = var.environment
  }
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
}