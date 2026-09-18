data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./modules/network"

  project_name = "main"
  environment  = "dev"
  cidr_block   = "10.0.0.0/16"
}

module "compute" {
  source = "./modules/compute"

  project_name = "main"
  environment  = "dev"
  vpc_id = module.vpc.vpc_id
}
