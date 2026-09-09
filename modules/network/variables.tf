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

variable "az_count" {
  description = "Number of active AZs"
  type        = number
  default     = 2
}
