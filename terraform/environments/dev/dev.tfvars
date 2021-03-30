environment = "dev"

# RDS
rds_storage_type = "standard"
rds_instance_class = "db.t3.micro"
rds_allocated_storage = 10

# REDIS
redis_node_type = "cache.t3.micro"


# Webserver
webserver_cpu = 1024 * 1
webserver_memory = 1024 * 2
webserver_desired_count = 1


# Scheduler
scheduler_cpu = 1024 * 1
scheduler_memory = 1024 * 2
scheduler_desired_count = 1


# Workers
worker_cpu = 1024 * 1
worker_memory = 1024 * 2
worker_desired_count = 1


# DAGs
dag_repo_url_template = "https://{}@github.com/GrokData/grok-airflow-dags.git"
