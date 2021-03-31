variable "profile" {
  description = "The profile to use to authenticate on AWS."
  type        = string
}

variable "region" {
  description = "AWS Region to create the Airflow cluster."
  type        = string
}

variable "project_name" {
  description = "Name to prefix all resource Name tags"
  type = string
}

variable "environment" {
  description = "The environment name to tag the deployment, e.g. Prod or Dev"
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

variable "redis_node_type" {
  description = "Node type for Redis cluster e.g. cache.t3.micro"
  type = string
}

variable "redis_port" {
  description = "Port to use for the Redis cluster"
  type = string
}

variable "webserver_cpu" {
  description = "CPUs to assign to webserver Fargate container"
  type = number
}

variable "webserver_memory" {
  description = "Memory to assign to webserver Fargate container"
  type = number
}

variable "webserver_desired_count" {
  description = "Desired count for webserver service tasks"
  type = number
}

variable "scheduler_cpu" {
  description = "CPUs to assign to scheduler Fargate container"
  type = number
}

variable "scheduler_memory" {
  description = "Memory to assign to scheduler Fargate container"
  type = number
}

variable "scheduler_desired_count" {
  description = "Desired count for scheduler service tasks"
  type = number
}

variable "worker_cpu" {
  description = "CPUs to assign to worker Fargate container"
  type = number
}

variable "worker_memory" {
  description = "Memory to assign to worker Fargate container"
  type = number
}

variable "worker_desired_count" {
  description = "Desired count for worker service tasks"
  type = number
}

variable "load_example_dags" {
  description = "y or n: load the example dags"
  type = string
  default = "n"
}

variable "dag_repo_url_template" {
  description = "Format string (Python) for the https url representing the DAG repo with a PAT. e.g. https://{}@github.com/GrokData/grok-airflow-dags.git"
  default = "https://{}@github.com/GrokData/grok-airflow-dags.git"
  type = string
  sensitive = true
}