#!/bin/bash

endpointUrl=http://${AWS_HOST}:${AWS_PORT}

function createLambda(){
    printf "zipping lambda \n"
    zip /docker-entrypoint-initaws.d/wallet-integration-function.zip /docker-entrypoint-initaws.d/wallet-integration-app

    printf "zipped lambda \n"
    aws --endpoint-url=${endpointUrl} lambda create-function --function-name wallet-integration \
    --zip-file fileb:///docker-entrypoint-initaws.d/wallet-integration-function.zip --handler main --runtime go1.x \
    --role arn:aws:iam::000000000000:role/lambda-ex
}

function createEventSourceMapping(){
    aws --endpoint-url=${endpointUrl} lambda create-event-source-mapping \
    --function-name wallet-integration --batch-size 1 \
    --event-source-arn arn:aws:sqs:us-east-1:000000000000:order-book-wallet-integration-queue
}

createLambda
createEventSourceMapping