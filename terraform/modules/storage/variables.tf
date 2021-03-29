variable "environment" {
  description = "The environment name to tag the deployment, e.g. Prod or Dev"
  type        = string
}

variable "project_name" {
  description = "Value of the Name tag for the resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the deploy VPC."
  type = string
}

variable "subnet_ids" {
  description = "Subnet IDs to mount the file system."
  type        = list(string)
}