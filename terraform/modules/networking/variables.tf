variable "environment" {
  description = "The environment name to tag the deployment, e.g. Prod or Dev"
  type        = string
}

variable "project_name" {
  description = "Value of the Name tag for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnets_cidr" {
  description = "CIDR block for the public subnet."
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "CIDR block for the private subnet."
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for the subnets."
  type = list(string)
}
