<<<<<<< HEAD
output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the created EKS cluster."
}

output "cluster_version" {
  value       = module.eks.cluster_version
  description = "The version of Kubernetes running on the EKS cluster."
=======
output "cluster_id" {
  value = module.eks.cluster_id
>>>>>>> 4ef94ccc0f6b63d82fd856b7a231dbacf9b91daa
}
output "cluster_endpoint" {
<<<<<<< HEAD
  value       = module.eks.cluster_endpoint
  description = "The endpoint for the EKS Kubernetes API server."
}

output "access_entries" {
  value = module.eks.access_entries
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn

}
output "acm_certificate_arn" {
  value = module.acm_backend.acm_certificate_arn

}
=======
  value = module.eks.cluster_endpoint
}
output "eks_version" {
  value = module.eks.cluster_version
}
output "node_security_group_id" {
  value = module.eks.cluster_security_group_id
}
output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region us-east-1 --name prod-eks"
}

>>>>>>> 4ef94ccc0f6b63d82fd856b7a231dbacf9b91daa
