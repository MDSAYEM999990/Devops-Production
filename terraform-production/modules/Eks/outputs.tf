output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS control plane endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = module.eks.cluster_id != null ? "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_id}" : "EKS cluster is not yet created"
}


output "node_security_group_id" {
  description = "Worker node security group ID"
  value       = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority" {
  description = "EKS cluster certificate authority"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_iam_role_name" {
  description = "IAM role name for the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "eks_version" {
  description = "EKS Kubernetes version"
  value       = module.eks.cluster_version
}


