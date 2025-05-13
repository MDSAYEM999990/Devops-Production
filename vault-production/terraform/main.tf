provider "aws" {
  region = var.region
}


module "vpc" {
  source     = "../modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "vault-vpc"
}

module "subnet" {
  source        = "../modules/subnets"
  vpc_id        = module.vpc.vpc_id
  region        = var.region
  subnet_a_cidr = "10.0.1.0/24"
}

module "iam" {
  source = "../modules/iam"
}

module "kms" {
  source = "../modules/kms"
}

module "s3" {
  source      = "../modules/s3"
  bucket_name = "iaccode9990-vault"
}

module "security_group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
}

module "vault_instance" {
  source                = "../modules/vault_instance"
  ami_id                = var.ami_id
  instance_type         = "t2.micro"
  subnet_id             = module.subnet.subnet_a_id
  sg_id                 = module.security_group.security_group_id
  key_name              = var.key_name
  instance_profile_name = module.iam.instance_profile_name
}
