module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "prod-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_iam_role" "vpc_cni" {
  name               = "prod-vpc-cni"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = module.eks.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-node"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role" "ebs_csi_driver" {
  name               = "prod-ebs-csi-driver"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = module.eks.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name                   = "prod-eks"
  cluster_version                = "1.28"
  cluster_endpoint_public_access = false
  enable_irsa                    = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cloudwatch_log_group_retention_in_days = 30
  enable_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_addons = {
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
    },
    kube-proxy = {
      most_recent = true
    },
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.vpc_cni.arn
    },
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
    }
  }

  eks_managed_node_groups = {
    on_demand = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 6
      desired_size   = 3
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"
      disk_size      = 30
    },
    spot = {
      instance_types = ["t3.large", "t3a.large"]
      min_size       = 1
      max_size       = 6
      desired_size   = 2
      capacity_type  = "SPOT"
      ami_type       = "AL2_x86_64"
      disk_size      = 30
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node communication"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    },
    egress_all = {
      description      = "Allow all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = {
    Environment = "prod"
    Owner       = "devops-team"
    CostCenter  = "project-x"
  }
}
