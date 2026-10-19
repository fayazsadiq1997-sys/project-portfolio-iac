# Terraform configuration

terraform {

  cloud {
    organization = "fayaz-practise"

    workspaces {
      project = "project-portfolio-iac"
      name    = "aws-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.69"
    }
  }
  required_version = "~> 1.2"
}
