#!/usr/bin/env bash

aws ecr get-login-password --region us-east-2 --profile default | docker login --username AWS --password-stdin 729750365617.dkr.ecr.us-east-2.amazonaws.com && \
    docker build --rm -t airflow-dev . && \
    docker tag airflow-dev:latest 729750365617.dkr.ecr.us-east-2.amazonaws.com/airflow-dev:latest && \
    docker push 729750365617.dkr.ecr.us-east-2.amazonaws.com/airflow-dev:latest
