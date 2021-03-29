resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.project_name}-${var.environment}-rds-credentials"
  description = "Username and password for the airflow RDS"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode(var.rds_credentials)
}

resource "aws_secretsmanager_secret" "webserver_secret_key" {
  name = "${var.project_name}-${var.environment}-webserver-secret-key"
  description = "Secret key for the airflow webserver"
}

resource "aws_secretsmanager_secret_version" "webserver_secret_key" {
  secret_id = aws_secretsmanager_secret.webserver_secret_key.id
  secret_string = var.webserver_secret_key
}

resource "aws_secretsmanager_secret" "webserver_fernet_key" {
  name = "${var.project_name}-${var.environment}-webserver-fernet-key"
  description = "Fernet key for the airflow webserver"
}

resource "aws_secretsmanager_secret_version" "webserver_fernet_key" {
  secret_id = aws_secretsmanager_secret.webserver_fernet_key.id
  secret_string = var.webserver_fernet_key
}

resource "aws_secretsmanager_secret" "webserver_admin_credentials" {
  name = "${var.project_name}-${var.environment}-webserver-admin-credentials"
  description = "Username, email, and password for the airflow webserver admin account"
}

resource "aws_secretsmanager_secret_version" "webserver_admin_credentials" {
  secret_id = aws_secretsmanager_secret.webserver_admin_credentials.id
  secret_string = jsonencode(var.webserver_admin_credentials)
}