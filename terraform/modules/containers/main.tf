/* ECR Repo */
resource "aws_ecr_repository" "repo" {
  name = lower("${var.project_name}-${var.environment}")
  tags = {
    Name = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

/* ECS Cluster */
resource "aws_ecs_cluster" "cluster" {
  name = lower("${var.project_name}-${var.environment}")
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  tags = {
    Name = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}


/* Init Task Definition */
resource "aws_ecs_task_definition" "init_task" {
  family = lower("${var.project_name}-${var.environment}-init-task")
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 1024
  memory = 1024 * 2
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name = "${var.project_name}-${var.environment}-init"
      image = "${aws_ecr_repository.repo.repository_url}:latest"
      command = ["init"]
      environment = [
        {
          name = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
          value = "postgresql+psycopg2://${var.rds_username}:${var.rds_password}@${var.rds_host}:${var.rds_port}/${var.rds_db_name}"
        },
        {
          name = "AIRFLOW_ADMIN_EMAIL"
          value = var.webserver_admin_email
        },
        {
          name = "AIRFLOW_ADMIN_USER"
          value = var.webserver_admin_username
        },
        {
          name = "AIRFLOW_ADMIN_PWD"
          value = var.webserver_admin_password
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = var.init_log_group_name
          awslogs-region = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

/* Webserver Task Definition */
resource "aws_ecs_task_definition" "webserver_task" {
  depends_on = [aws_ecs_task_definition.init_task]
  family = lower("${var.project_name}-${var.environment}-webserver-task")
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.webserver_cpu
  memory = var.webserver_memory
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name = "${var.project_name}-${var.environment}-webserver"
      image = "${aws_ecr_repository.repo.repository_url}:latest"
      essential = true
      command = ["webserver"]
      environment = [
        {
          name = "AIRFLOW__WEBSERVER__SECRET_KEY"
          value = var.webserver_secret_key
        },
        {
          name = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
          value = "postgresql+psycopg2://${var.rds_username}:${var.rds_password}@${var.rds_host}:${var.rds_port}/${var.rds_db_name}"
        },
        {
          name = "AIRFLOW__CORE__EXECUTOR"
          value = "CeleryExecutor"
        },
        {
          name = "AIRFLOW__CELERY__RESULT_BACKEND"
          value = "db+postgresql://${var.rds_username}:${var.rds_password}@${var.rds_host}:${var.rds_port}/${var.rds_db_name}"
        },
        {
          name = "AIRFLOW__CORE__FERNET_KEY"
          value = var.webserver_fernet_key
        },
        {
          name = "LOAD_EX"
          value = var.load_example_dags
        }
      ]
      portMappings = [
        {
          containerPort = 8080
          hostPort = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = var.webserver_log_group_name
          awslogs-region = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints= [
          {
              containerPath= "/usr/local/dag-repo",
              sourceVolume= "efs-dag-repo"
          }
      ],
    }
  ])

  volume {
    name      = "efs-dag-repo"
    efs_volume_configuration {
      file_system_id = var.dag_efs_id
      root_directory = "/"
    }
  }
}

/* Webserver ALB Security Group */
resource "aws_security_group" "alb_security_group" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}


/* Webserver ALB */
resource "aws_lb" "webserver_lb" {
  name = lower("${var.project_name}-${var.environment}-webserver-lb")
  internal = false
  load_balancer_type = "application"
  subnets = var.webserver_lb_subnets
  security_groups = [aws_security_group.alb_security_group.id, var.vpc_default_security_group_id]
}

resource "aws_lb_listener" "webserver_lb_listener" {
  load_balancer_arn = aws_lb.webserver_lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.webserver_lb_tg.arn
  }
}

resource "aws_lb_target_group" "webserver_lb_tg" {
  name = lower("${var.project_name}-${var.environment}-webserver-lb-tg")
  protocol = "HTTP"
  target_type = "ip"
  port = 80
  vpc_id = var.vpc_id
  health_check {
    path = "/health"
    timeout = 30
    interval = 60
    healthy_threshold = 5
    unhealthy_threshold = 5
  }
}


/* Webserver Service */
resource "aws_ecs_service" "webserver_service" {
  name = lower("${var.project_name}-${var.environment}-webserver-service")
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.webserver_task.arn
  desired_count = var.webserver_desired_count
  launch_type = "FARGATE"
  force_new_deployment = true
  network_configuration {
    subnets = var.webserver_subnets
    security_groups = [var.vpc_default_security_group_id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.webserver_lb_tg.arn
    container_name = "${var.project_name}-${var.environment}-webserver"
    container_port = 8080
  }
}

/* Scheduler Task Definition */
resource "aws_ecs_task_definition" "scheduler_task" {
  depends_on = [aws_ecs_task_definition.init_task]
  family = lower("${var.project_name}-${var.environment}-scheduler-task")
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.scheduler_cpu
  memory = var.scheduler_memory
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name = "${var.project_name}-${var.environment}-scheduler"
      image = "${aws_ecr_repository.repo.repository_url}:latest"
      essential = true
      command = ["scheduler"]
      environment = [
        {
          name = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
          value = "postgresql+psycopg2://${var.rds_username}:${var.rds_password}@${var.rds_host}:${var.rds_port}/${var.rds_db_name}"
        },
        {
          name = "AIRFLOW__CORE__EXECUTOR"
          value = "CeleryExecutor"
        },
        {
          name = "AIRFLOW__CELERY__RESULT_BACKEND"
          value = "db+postgresql://${var.rds_username}:${var.rds_password}@${var.rds_host}:${var.rds_port}/${var.rds_db_name}"
        },
        {
          name = "AIRFLOW__CELERY__BROKER_URL"
          value = "redis://${var.redis_host}:${var.redis_port}/0"
        },
        {
          name = "LOAD_EX"
          value = var.load_example_dags
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = var.scheduler_log_group_name
          awslogs-region = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints= [
          {
              containerPath= "/usr/local/dag-repo",
              sourceVolume= "efs-dag-repo"
          }
      ],
    }
  ])

  volume {
    name      = "efs-dag-repo"
    efs_volume_configuration {
      file_system_id = var.dag_efs_id
      root_directory = "/"
    }
  }
}
/* Scheduler Service */
resource "aws_ecs_service" "scheduler_service" {
  name = lower("${var.project_name}-${var.environment}-scheduler-service")
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.scheduler_task.arn
  desired_count = var.scheduler_desired_count
  launch_type = "FARGATE"
  force_new_deployment = true
  network_configuration {
    subnets = var.scheduler_subnets
    security_groups = [var.vpc_default_security_group_id]
  }
}


/* Worker Task Definition */
resource "aws_ecs_task_definition" "worker_task" {
  depends_on = [aws_ecs_task_definition.init_task]
  family = lower("${var.project_name}-${var.environment}-worker-task")
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.worker_cpu
  memory = var.worker_memory
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name = "${var.project_name}-${var.environment}-worker"
      image = "${aws_ecr_repository.repo.repository_url}:latest"
      essential = true
      command = ["worker"]
      environment = [
        {
          name = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
          value = "postgresql+psycopg2://${var.rds_username}:${var.rds_password}@${var.rds_host}:${var.rds_port}/${var.rds_db_name}"
        },
        {
          name = "AIRFLOW__CORE__EXECUTOR"
          value = "CeleryExecutor"
        },
        {
          name = "AIRFLOW__CELERY__RESULT_BACKEND"
          value = "db+postgresql://${var.rds_username}:${var.rds_password}@${var.rds_host}:${var.rds_port}/${var.rds_db_name}"
        },
        {
          name = "AIRFLOW__CELERY__BROKER_URL"
          value = "redis://${var.redis_host}:${var.redis_port}/0"
        },
        {
          name = "LOAD_EX"
          value = var.load_example_dags
        }
      ]
      portMappings = [
        {
          containerPort = 8793
          hostPort = 8793
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = var.worker_log_group_name
          awslogs-region = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints= [
          {
              containerPath= "/usr/local/dag-repo",
              sourceVolume= "efs-dag-repo"
          }
      ],
    }
  ])

  volume {
    name      = "efs-dag-repo"
    efs_volume_configuration {
      file_system_id = var.dag_efs_id
      root_directory = "/"
    }
  }
}

/* Worker Service */
resource "aws_ecs_service" "worker_service" {
  name = lower("${var.project_name}-${var.environment}-worker-service")
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.worker_task.arn
  desired_count = var.worker_desired_count
  launch_type = "FARGATE"
  force_new_deployment = true
  network_configuration {
    subnets = var.worker_subnets
    security_groups = [var.vpc_default_security_group_id]
  }
}