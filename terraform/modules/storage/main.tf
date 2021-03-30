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
  security_groups = [aws_security_group.efs_security_group.id, var.vpc_default_security_group_id]
}

/* Access Point for EFS/Lambda */
resource "aws_efs_access_point" "efs_lambda_access_point" {
  file_system_id = aws_efs_file_system.efs.id

  root_directory {
    path = "/efs"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "777"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }
}

/* Lambda to update the code */
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name = "git_update_lambda_policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeMountTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  }
}

resource "aws_lambda_layer_version" "git_layer" {
  layer_name = "git-layer"
  filename = "./modules/storage/git_layer.zip"
  source_code_hash = filebase64sha256("./modules/storage/git_layer.zip")
}

resource "aws_lambda_function" "update_dag_repo_lambda" {

  filename = "./modules/storage/update_dag_repo.zip"
  function_name = lower("${var.project_name}-${var.environment}-dag-repo-update")
  handler = "update_dag_repo.update_dag_repo"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime = "python3.8"
  layers = [aws_lambda_layer_version.git_layer.arn]

  source_code_hash = filebase64sha256("./modules/storage/update_dag_repo.zip")

  file_system_config {
    # EFS file system access point ARN
    arn = aws_efs_access_point.efs_lambda_access_point.arn

    # Local mount path inside the lambda function. Must start with '/mnt/'.
    local_mount_path = "/mnt/efs"
  }

  environment {
    variables = {
      ACCESS_TOKEN = var.dag_repo_access_token
      TARGET_DIR = "/mnt/efs/dag-repo"
      REPO_URL_TEMPLATE = var.dag_repo_url_template
    }
  }

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.vpc_default_security_group_id]
  }

  # Explicitly declare dependency on EFS mount target.
  # When creating or updating Lambda functions, mount target must be in 'available' lifecycle state.
  depends_on = [aws_efs_mount_target.mount]
}