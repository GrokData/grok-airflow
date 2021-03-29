/* RDS Security Group */
resource "aws_security_group" "rds_security_group" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port = var.rds_port
    to_port   = var.rds_port
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

/* RDS Instance */
resource "aws_db_instance" "rds" {
  depends_on = [aws_security_group.rds_security_group]
  identifier = lower("${var.project_name}-${var.environment}-RDS")
  storage_type = var.rds_storage_type
  allocated_storage = var.rds_allocated_storage
  engine = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class
  name = var.rds_db_name
  port = var.rds_port
  username = var.rds_username
  password = var.rds_password
  publicly_accessible = false
  apply_immediately = true
//  final_snapshot_identifier = "${var.project_name}-${var.environment}-final-snapshot"
  skip_final_snapshot = true
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id, var.vpc_default_security_group_id]
  tags = {
    Name: "${var.project_name}-${var.environment}"
    Environment: var.environment
  }

}

/* Redis Security Group */
resource "aws_security_group" "redis_security_group" {
  name        = "${var.project_name}-${var.environment}-redis-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port = var.redis_port
    to_port   = var.redis_port
    protocol  = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-sg"
    Environment = var.environment
  }
}


/* Redis Cluster */
resource "aws_elasticache_cluster" "redis" {
  cluster_id = lower("${var.project_name}-${var.environment}-REDIS")
  engine = "redis"
  node_type = var.redis_node_type
  num_cache_nodes = 1
  port = var.redis_port
  subnet_group_name = var.redis_subnet_group_name
  security_group_ids = [aws_security_group.redis_security_group.id, var.vpc_default_security_group_id]
}