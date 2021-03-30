module "secrets" {
  source = "./modules/secrets"
  environment = var.environment
  project_name = var.project_name
}

module "networking" {
  source = "./modules/networking"
  environment = var.environment
  project_name = var.project_name
  vpc_cidr = var.vpc_cidr
  public_subnets_cidr = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones = var.availability_zones
}

module "logging" {
  source = "./modules/logging"
  environment = var.environment
  project_name = var.project_name
}

module "databases" {
  source = "./modules/databases"
  environment = var.environment
  project_name = var.project_name
  vpc_id = module.networking.vpc_id
  vpc_cidr = module.networking.vpc_cidr
  rds_allocated_storage = 10
  rds_storage_type = var.rds_storage_type
  rds_engine = var.rds_engine
  rds_engine_version = var.rds_engine_version
  rds_instance_class = var.rds_instance_class
  rds_db_name = var.rds_db_name
  rds_port = var.rds_port
  rds_username = module.secrets.rds_username
  rds_password = module.secrets.rds_password
  db_subnet_group_name = module.networking.db_subnet_group_name
  redis_node_type = var.redis_node_type
  redis_subnet_group_name = module.networking.redis_subnet_group_name
  redis_port = var.redis_port
  vpc_default_security_group_id = module.networking.vpc_default_security_group_id
}

module "storage" {
  source = "./modules/storage"
  environment = var.environment
  project_name = var.project_name
  vpc_id = module.networking.vpc_id
  vpc_cidr = module.networking.vpc_cidr
  subnet_ids = module.networking.private_subnet_ids
  vpc_default_security_group_id = module.networking.vpc_default_security_group_id
  dag_repo_access_token = module.secrets.dag_repo_access_token
  dag_repo_url_template = var.dag_repo_url_template
}

module "containers" {
  source = "./modules/containers"
  environment = var.environment
  project_name = var.project_name
  region = var.region
  rds_db_name = var.rds_db_name
  rds_host = module.databases.rds_host
  redis_host = module.databases.redis_host
  redis_port = var.redis_port
  rds_password = module.secrets.rds_password
  rds_username = module.secrets.rds_username
  rds_port = var.rds_port
  vpc_id = module.networking.vpc_id
  webserver_availability_zones = var.availability_zones
  webserver_subnets = module.networking.private_subnet_ids
  webserver_lb_subnets = module.networking.public_subnet_ids
  webserver_cpu = var.webserver_cpu
  webserver_memory = var.webserver_memory
  webserver_desired_count = var.webserver_desired_count
  webserver_secret_key = module.secrets.webserver_secret_key
  webserver_fernet_key = module.secrets.webserver_fernet_key
  webserver_log_group_name = module.logging.webserver_log_group_name
  init_log_group_name = module.logging.init_log_group_name
  scheduler_log_group_name = module.logging.scheduler_log_group_name
  worker_log_group_name = module.logging.worker_log_group_name
  vpc_default_security_group_id = module.networking.vpc_default_security_group_id
  webserver_admin_email = module.secrets.webserver_admin_email
  webserver_admin_username = module.secrets.webserver_admin_username
  webserver_admin_password = module.secrets.webserver_admin_password
  scheduler_cpu = var.scheduler_cpu
  scheduler_memory = var.scheduler_memory
  scheduler_desired_count = var.scheduler_desired_count
  scheduler_subnets = module.networking.private_subnet_ids
  worker_cpu = var.worker_cpu
  worker_memory = var.worker_memory
  worker_desired_count = var.worker_desired_count
  worker_subnets = module.networking.private_subnet_ids
  load_example_dags = "y"
  dag_efs_id = module.storage.dag_efs_id
}

