output "init_log_group_name" {
  value = lower("/ecs/${var.project_name}-${var.environment}-init-task")
}

output "webserver_log_group_name" {
  value = lower("/ecs/${var.project_name}-${var.environment}-webserver-task")
}

output "scheduler_log_group_name" {
  value = lower("/ecs/${var.project_name}-${var.environment}-scheduler-task")
}

output "worker_log_group_name" {
  value = lower("/ecs/${var.project_name}-${var.environment}-worker-task")
}