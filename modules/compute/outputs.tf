output "ecr_repository_url" {
  description = "URL of the created ECR Repo"
  value       = aws_ecr_repository.app.repository_url
}
