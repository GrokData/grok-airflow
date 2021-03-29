output "rds_username" {
  value = jsondecode(aws_secretsmanager_secret_version.rds_credentials.secret_string)["rds_username"]
  sensitive = true
}

output "rds_password" {
  value = jsondecode(aws_secretsmanager_secret_version.rds_credentials.secret_string)["rds_password"]
  sensitive = true
}

output "webserver_secret_key" {
  value = aws_secretsmanager_secret_version.webserver_secret_key.secret_string
  sensitive = true
}

output "webserver_fernet_key" {
  value = aws_secretsmanager_secret_version.webserver_fernet_key.secret_string
  sensitive = true
}

output "webserver_admin_email" {
  value = jsondecode(aws_secretsmanager_secret_version.webserver_admin_credentials.secret_string)["email"]
  sensitive = true
}

output "webserver_admin_username" {
  value = jsondecode(aws_secretsmanager_secret_version.webserver_admin_credentials.secret_string)["username"]
  sensitive = true
}

output "webserver_admin_password" {
  value = jsondecode(aws_secretsmanager_secret_version.webserver_admin_credentials.secret_string)["password"]
  sensitive = true
}