variable "environment" {
  description = "The environment name to tag the deployment, e.g. Prod or Dev"
  type        = string
}

variable "project_name" {
  description = "Value of the Name tag for the RDS"
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

variable "rds_allocated_storage" {
  description = "Allocated storage in gibibytes"
  type = number
}

variable "rds_storage_type" {
  description = "Storage type for the RDS instance"
  type = string
}

variable "rds_engine" {
  description = "Engine for the RDS e.g. postgresql, mysql"
  type = string
}

variable "rds_engine_version" {
  description = "Engine version for the RDS instance"
  type = string
}

variable "rds_instance_class" {
  description = "Instance class for the RDS e.g. db.t3.micro"
  type = string
}

variable "rds_db_name" {
  description = "Name of the database to create"
  type = string
}

variable "rds_port" {
  description = "Port to use for the RDS instance"
  type = string
}

variable "rds_username" {
  description = "RDS Username"
  type = string
  sensitive = true
}

variable "rds_password" {
  description = "RDS Password"
  type = string
  sensitive = true
}

variable "db_subnet_group_name" {
  description = "Name of the subnet group to create the RDS instance"
  type = string
}

variable "redis_subnet_group_name" {
  description = "Name of the subnet group to create the Redis cluster"
  type = string
}

variable "redis_node_type" {
  description = "Node type for Redis cluster e.g. cache.t3.micro"
  type = string
}

variable "redis_port" {
  description = "Port to use for the Redis cluster"
  type = string
}

variable "vpc_default_security_group_id" {
  description = "ID for default security group of VPC"
  type = string
}