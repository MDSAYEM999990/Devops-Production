output "cluster_id" {
  value = module.eks.cluster_id
}
output "cluster_endpoint" {
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

