/* Security Group */
resource "aws_security_group" "efs_security_group" {
  name        = "${var.project_name}-${var.environment}-efs-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port = "2049"
    to_port   = "2049"
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
    Name = "${var.project_name}-${var.environment}-efs-sg"
    Environment = var.environment
  }
}

/* EFS Volume */
resource "aws_efs_file_system" "efs" {
  creation_token = lower("${var.project_name}-${var.environment}-efs")
  tags = {
    Name = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

/* EFS Mount Point */
resource "aws_efs_mount_target" "mount" {
  file_system_id = aws_efs_file_system.efs.id
  count = length(var.subnet_ids)
  subnet_id = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.efs_security_group.id]
}