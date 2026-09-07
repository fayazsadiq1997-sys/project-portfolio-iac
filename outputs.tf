output "assumed_role_arn" {
  description = "Identity the HCP run authenticated as. Proves OIDC role assumption works."
  value       = data.aws_caller_identity.current.arn
}
