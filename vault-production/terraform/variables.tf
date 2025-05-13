variable "region" {
  description = "AWS region"
  type        = string
  }

variable "ami_id" {
  description = "Vault EC2 instance AMI"
  type        = string
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}
