#!/bin/bash

DOCKER_USER=dancu25
IMAGE_NAME=test-site
TAG=latest

docker build -t $DOCKER_USER/$IMAGE_NAME:$TAG .
docker push $DOCKER_USER/$IMAGE_NAME:$TAG