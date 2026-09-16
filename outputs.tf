output "assumed_role_arn" {
  description = "Identity the HCP run authenticated as. Proves OIDC role assumption works."
  value       = data.aws_caller_identity.current.arn
}

output "vpc_id" {
  description = "ID of the VPC created in network module"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "URL for created ECR Repo"
  value       = module.compute.ecr_repository_url
}

