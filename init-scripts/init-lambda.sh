#!/bin/bash

endpointUrl=http://${AWS_HOST}:${AWS_PORT}

function configure(){
    export AWS_ACCESS_KEY_ID=default_access_key
    export AWS_SECRET_ACCESS_KEY=default_secret_key
    export AWS_DEFAULT_REGION=sa-east-1

    aws configure set AWS_ACCESS_KEY_ID default_access_key
    aws configure set AWS_SECRET_ACCESS_KEY default_secret_key
    aws configure set AWS_DEFAULT_REGION sa-east-1

}
function createQueue() {
    aws --endpoint-url=${endpointUrl} sqs create-queue --queue-name order-book-wallet-integration-queue
}

function createRole() {
    aws --endpoint-url=${endpointUrl} iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
    aws --endpoint-url=${endpointUrl} iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
}

function createLambda(){
    printf "ziping lambda \n"
    zip /docker-entrypoint-initaws.d/function.zip /docker-entrypoint-initaws.d/main

    printf "ziped lambda \n"

    aws --endpoint-url=${endpointUrl} lambda create-function --function-name my-function \
    --zip-file fileb:///docker-entrypoint-initaws.d/function.zip --handler main --runtime go1.x \
    --role arn:aws:iam::000000000000:role/lambda-ex
}

function createEventSourceMapping(){
    dynamodbStreamArn=$(aws --endpoint-url=${endpointUrl} dynamodbstreams list-streams --table-name order-book-operation | grep StreamArn | sed -r 's/^[^:]*:(.*)$/\1/')
    dynamodbStreamArn=${dynamodbStreamArn:2:-2}
    printf "DynamoDB StreamArn: $dynamodbStreamArn \n"

    aws --endpoint-url=${endpointUrl} lambda create-event-source-mapping \
    --function-name my-function --batch-size 1 \
    --event-source-arn $dynamodbStreamArn
}

configure
createQueue
createRole
createLambda
createEventSourceMapping