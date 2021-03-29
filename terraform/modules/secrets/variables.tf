variable "environment" {
  description = "The environment name to tag the deployment, e.g. Prod or Dev"
  type        = string
}

variable "project_name" {
  description = "Value of the Name tag for the VPC"
  type        = string
}

variable "rds_credentials" {
  description = "Credentials for the RDS instance"
  type = map(string)
  sensitive = true
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

variable "webserver_admin_credentials" {
  description = "Admin credentials to user for the airflow webserver"
  type = map(string)
  sensitive = true
}