# Grok Data Airflow Template
This repo provides instructions and automation to generate a new airflow cluster within a new VPC in AWS.

### Contents
There are two main subdirectories:
- `/airflow`, containing a dockerized version of Airflow.
- `/terraform`, containing terraform code to spin up all necessary AWS resources for a secure and scalable Airflow deployment.

### Architecture
If you were to use this repo with all default configurations, we would create the following resources:  
- **Secrets**
  - A Secret/Version containing key/value pairs for the rds username and password
  - A Secret/Version containing the webserver secret key
  - A Secret/Version containing the webserver fernet key
  - A Secret/Version containing key/value pairs for the initial webserver admin email, username, and password
- **Networking**
  - A dedicated VPC
  - 2 Public subnets
  - 1 Private subnet
  - an NAT and Internet Gateway to allow for connectivity of instances in the private subnet
  - an Elastic IP for the NAT
  - Route tables for the subnets/NAT/IGW
  - a DB subnet group attached to the private subnet
  - an elasticache subnet group attached to the private subnet
  - a Default VPC security group allowing ingress from within the VPC
- **Databases**
  - A security group for the RDS allowing ingress to the RDS port
  - A postgres RDS launched in the db subnet group
  - A security group for the Redis cluster allowing ingress to the Redis port
  - a Redis cluster launched in the elasticache subnet group
- **Containers**
  - An ECR repo for the Airflow image
  - An ECS cluster for the deployment using Fargate
  - A task definition for each of the following components:
    - `init` to init the airflow db and create the first Admin user
    - `webserver`
    - `scheduler`
    - `worker`
  - A service for each of the following components:
    - `webserver`
    - `scheduler`
    - `worker`
  - An Application Load Balancer, Target Group, and Listener for the Web Server container(s)
- **Storage**
  - A security group for EFS
  - An EFS volume for the DAG/module repo
  - An EFS mount in the private subnets

### Deploying a new Airflow cluster with this repo
This repo is meant as a template paired with the `grok-airflow-dags` repo and contains all you need to create a new Airflow cluster from scratch. It's not meant to be immediately usable for all production scenarios. For example, by default this will create a new VPC, subnets, etc. but you may already have a VPC, database, etc. in production that you prefer to use. In these cases, you should modify the terraform modules to use `data` components rather than `resource` components to signify that some of the resources already exist.

To start a net-new Airflow deployment from scratch, the procedure is fairly simple:
- Read through the README in the `terraform` directory and learn how to define necessary variables for your custom deployment.
- After setting the variables, create the AWS resources by running `terraform init` and then `terraform apply` with your `--var-file` options set.
- While/after the resources are created, edit and run the `build_and_push_image_<env>.sh` files within the `airflow` directory to build the airflow image and push to the ECR repo. The necessary changes to these files will be to alter the account, region, and profile for the deployment.
- Once these resources are created, follow the instructions in the `grok-airflow-dags` template repo to make sure your dag/module repo is synced to the EFS drive so that your airflow cluster receives your latest copy.



