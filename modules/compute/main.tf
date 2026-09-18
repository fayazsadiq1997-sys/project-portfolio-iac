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

# Trust policy. Currently used by task role and execution role.
data "aws_iam_policy_document" "ecs_tasks_assume" {
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
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
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

#Task role: Assumed by running containers code from SDK 
resource "aws_iam_role" "task" {
  name = "${local.name_prefix}task"
  #Reuse execution role trust doc, both roles are used by ecs-tasks.amazonaws.com
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

#ECS Cluster (Fargate)
resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}cluster"
}

#Security Group
resource "aws_security_group" "task" {
  name        = "${local.name_prefix}task"
  description = "ECS Task ENI SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}task"
  }
}

resource "aws_vpc_security_group_egress_rule" "task_https_egress" {
  security_group_id = aws_security_group.task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 443
  to_port = 443
}

