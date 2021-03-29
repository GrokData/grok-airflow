#!/usr/bin/env bash

aws ecr get-login-password --region <region> --profile <profile> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com && \
    docker build --rm -t airflow-<env> . && \
    docker tag airflow-<env>:latest <account_id>.dkr.ecr.<region>.amazonaws.com/airflow-<env>:latest && \
    docker push <account_id>.dkr.ecr.<region>.amazonaws.com/airflow-<env>:latest
