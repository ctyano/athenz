#!/usr/bin/env bash
set -ev

echo "-----------------------------------------------"
echo "Creating Athenz Docker image..."
echo "-----------------------------------------------"

docker build -t tatyano/athenz .
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
echo "tagging Athenz Docker image with tag: latest"
docker tag tatyano/athenz tatyano/athenz:latest
docker push tatyano/athenz

echo "-----------------------------------------------"
echo "Athenz Docker Image Completed"
echo "-----------------------------------------------"
