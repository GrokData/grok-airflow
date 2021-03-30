
data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = lower("${var.project_name}-${var.environment}-rds-credentials")
}


data "aws_secretsmanager_secret_version" "webserver_secret_key" {
  secret_id = lower("${var.project_name}-${var.environment}-webserver-secret-key")
}


data "aws_secretsmanager_secret_version" "webserver_fernet_key" {
  secret_id = lower("${var.project_name}-${var.environment}-webserver-fernet-key")
}


data "aws_secretsmanager_secret_version" "webserver_admin_credentials" {
  secret_id = lower("${var.project_name}-${var.environment}-webserver-admin-credentials")
}

data "aws_secretsmanager_secret_version" "dag_repo_access_token" {
  secret_id = lower("${var.project_name}-${var.environment}-dag-repo-access-token")
}