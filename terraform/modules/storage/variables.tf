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

variable "vpc_default_security_group_id" {
  description = "ID for default security group of VPC"
  type = string
}

variable "dag_repo_access_token" {
  description = "Personal Access Token for the repo containing your dag code."
  type = string
  sensitive = true
}

variable "dag_repo_url_template" {
  description = "Format string (Python) for the https url representing the DAG repo with a PAT. e.g. https://{}@github.com/GrokData/grok-airflow-dags.git"
  default = "https://{}@github.com/GrokData/grok-airflow-dags.git"
  type = string
  sensitive = true
}