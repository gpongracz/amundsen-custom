#!/usr/bin/env bash

# Read the config
source ./PROJECT_CONFIG

MODULE=search

COMPONENT_NAME="$PROJECT_NAME-$MODULE"

ON_EC2=`curl -sL -w "%{http_code}\\n" "http://169.254.169.254/latest/meta-data/" -o /dev/null -m 5`

echo "ON EC2: $ON_EC2"

if [ "$ON_EC2" = "200" ]; then
    export AWS_ECR_ACCOUNT_ID=`curl -sL http://169.254.169.254/latest/meta-data/identity-credentials/ec2/info/ | jq -r '.AccountId'`
fi

echo "ON AWS_ECR_ACCOUNT_ID: $AWS_ECR_ACCOUNT_ID"

docker build -f Dockerfile.search -t $COMPONENT_NAME .
docker tag $COMPONENT_NAME $COMPONENT_NAME:latest
docker tag $COMPONENT_NAME:latest $AWS_ECR_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$COMPONENT_NAME:latest
echo "Built image $COMPONENT_NAME:latest"
