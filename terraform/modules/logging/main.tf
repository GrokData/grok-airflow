resource "aws_cloudwatch_log_group" "init_log_group" {
  name = lower("/ecs/${var.project_name}-${var.environment}-init-task")
}

resource "aws_cloudwatch_log_group" "webserver_log_group" {
  name = lower("/ecs/${var.project_name}-${var.environment}-webserver-task")
}

resource "aws_cloudwatch_log_group" "scheduler_log_group" {
  name = lower("/ecs/${var.project_name}-${var.environment}-scheduler-task")
}

resource "aws_cloudwatch_log_group" "worker_log_group" {
  name = lower("/ecs/${var.project_name}-${var.environment}-worker-task")
}

