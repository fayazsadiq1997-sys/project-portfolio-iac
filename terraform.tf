# Terraform configuration

terraform {

  cloud {
    organization = "fayaz-practise"

    workspaces {
      project = "project-portfolio-iac"
      name = "aws-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.24.0"
    }
  }
  required_version = "~> 1.2"
}
