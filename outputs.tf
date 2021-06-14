## Show outputs in root so that they are persisted in the terraform state
output "vpc" {
  value = module.vpc.name
}

output "vpc_region" {
  value = module.vpc.region
}

output "vpc_id" {
  value = module.vpc.id
}

output "public_subnet_ids" {
  value = module.public_subnets.public_subnet_ids
}

output "public_subnet_cidrs" {
  value = module.public_subnets.public_subnet_cidrs
}

output "eks_kubeconfig" {
  value = module.eks.eks_kubeconfig
}

output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}