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

configure
createQueue
createRole