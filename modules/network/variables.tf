# Input variable definitions

variable "cidr_block" {
  description = "CIDR Block"
  type        = string
}

variable "project_name" {
  description = "Name of Project"
  type        = string
}

variable "environment" {
  description = "Current Environment"
  type        = string
}
