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

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name_prefix}app"
  retention_in_days = 7
}

# Trust policy
data "aws_iam_policy_document" "execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Execution Role
resource "aws_iam_role" "execution" {
  name               = "${local.name_prefix}execution"
  assume_role_policy = data.aws_iam_policy_document.execution_assume.json
}

# Permissions document
data "aws_iam_policy_document" "execution_permissions" {
  statement {
    sid       = "EcrAuthToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "EcrPullImage"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [aws_ecr_repository.app.arn]
  }

  statement {
    sid       = "WriteAppLogs"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.app.arn}:*"]
  }
}

# Bind the permissions to the role
resource "aws_iam_role_policy" "execution" {
  name   = "${local.name_prefix}execution-policy"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution_permissions.json
}
