module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name                   = var.cluster_name
  cluster_version                = var.kubernetes_version
  cluster_endpoint_public_access = false  # 🔐 Public access বন্ধ করে internal only access

  enable_irsa = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    on_demand = {
      name            = "on-demand-ng"
      instance_types  = ["t3.medium"]
      desired_size    = 1
      min_size        = 1
      max_size        = 3
      capacity_type   = "ON_DEMAND"
      ami_type        = "AL2_x86_64"
      disk_size       = 50

      cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id

      tags = {
        Environment = "prod"
      }
    }

    spot = {
      name            = "spot-ng"
      instance_types  = ["t3.medium", "t3.large"]
      desired_size    = 2
      min_size        = 1
      max_size        = 6
      capacity_type   = "SPOT"
      ami_type        = "AL2_x86_64"
      disk_size       = 50

      cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id

      tags = {
        Environment = "prod"
        Lifecycle   = "spot"
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Allow all outbound"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  
}
