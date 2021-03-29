variable "environment" {
  description = "The environment name to tag the deployment, e.g. Prod or Dev"
  type        = string
}

variable "project_name" {
  description = "Value of the Name tag for the RDS"
  type        = string
}

variable "region" {
  description = "AWS Region to create the Airflow cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy resources."
  type        = string
}

variable "webserver_cpu" {
  description = "CPUs to assign to webserver Fargate container"
  type = number
}

variable "webserver_memory" {
  description = "Memory to assign to webserver Fargate container"
  type = number
}

variable "webserver_secret_key" {
  description = "Secret key to assign to webserver Flask app"
  type = string
  sensitive = true
}

variable "webserver_fernet_key" {
  description = "Fernet key to assign to webserver Flask app"
  type = string
  sensitive = true
}

variable "webserver_desired_count" {
  description = "Desired count for webserver service tasks"
  type = number
}

variable "webserver_subnets" {
  description = "Subnets to deploy the webserver"
  type = list(string)
}

variable "webserver_availability_zones" {
  description = "AZs to deploy the webserver"
  type = list(string)
}

variable "webserver_lb_subnets" {
  description = "Subnets to deploy the webserver load balancer"
  type = list(string)
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

variable "scheduler_subnets" {
  description = "Subnets to deploy the scheduler"
  type = list(string)
}

variable "rds_host" {
  description = "RDS host"
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

variable "redis_host" {
  description = "Redis host"
  type = string
}

variable "redis_port" {
  description = "Port to use for the Redis instance"
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


variable "init_log_group_name" {
  description = "CloudWatch logging group for init container"
  type = string
}

variable "webserver_log_group_name" {
  description = "CloudWatch logging group for webserver container"
  type = string
}

variable "scheduler_log_group_name" {
  description = "CloudWatch logging group for scheduler container"
  type = string
}

variable "worker_log_group_name" {
  description = "CloudWatch logging group for worker container"
  type = string
}

variable "vpc_default_security_group_id" {
  description = "ID for default security group of VPC"
  type = string
}

variable "webserver_admin_email" {
  description = "Email for the airflow admin account"
  sensitive = true
}

variable "webserver_admin_username" {
  description = "Username for the airflow admin account"
  sensitive = true
}

variable "webserver_admin_password" {
  description = "Password for the airflow admin account"
  sensitive = true
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

variable "worker_subnets" {
  description = "Subnets to deploy the workers"
  type = list(string)
}

variable "load_example_dags" {
  description = "y or n: load the example dags"
  type = string
  default = "n"
}

variable "dag_efs_id" {
  description = "ID for the EFS hosting the dag and module code"
  type = string
}