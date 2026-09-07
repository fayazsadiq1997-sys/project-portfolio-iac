data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./modules/network"

  project_name = "Main"
  environment  = "Dev"
  cidr_block   = "10.0.0.0/16"
}
