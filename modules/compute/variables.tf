variable "project_name" {
  description = "Name of Project"
  type        = string
}

variable "environment" {
  description = "Current Environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "image_tag" {
  description = "Image tag used by ECS Task definition"
  type        = string
}

variable "container_port" {
  description = "Container port used by Fargate"
  type        = number
  default     = 80
}
