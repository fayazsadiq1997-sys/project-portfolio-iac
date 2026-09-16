locals {
  name_prefix = "${var.project_name}-${var.environment}-"
}

resource "aws_ecr_repository" "app" {
  name                 = "${local.name_prefix}app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "${local.name_prefix}app"
  }
}
