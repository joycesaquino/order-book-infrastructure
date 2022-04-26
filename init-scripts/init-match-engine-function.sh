#!/bin/bash

endpointUrl=http://${AWS_HOST}:${AWS_PORT}

function createLambda(){
    printf "zipping lambda \n"
    zip /docker-entrypoint-initaws.d/match-angine-function.zip /docker-entrypoint-initaws.d/match-engine-app

    printf "zipped lambda \n"

    aws --endpoint-url=${endpointUrl} lambda create-function --function-name order-book-match-engine \
    --zip-file fileb:///docker-entrypoint-initaws.d/match-angine-function.zip --handler main --runtime go1.x \
    --role arn:aws:iam::000000000000:role/lambda-ex
}

function createEventSourceMapping(){
    dynamodbStreamArn=$(aws --endpoint-url=${endpointUrl} dynamodbstreams list-streams --table-name order-book-operation | grep StreamArn | sed -r 's/^[^:]*:(.*)$/\1/')
    dynamodbStreamArn=${dynamodbStreamArn:2:-2}
    printf "DynamoDB StreamArn: $dynamodbStreamArn \n"

    aws --endpoint-url=${endpointUrl} lambda create-event-source-mapping \
    --function-name order-book-match-engine --batch-size 1 \
    --event-source-arn $dynamodbStreamArn
}

createLambda
createEventSourceMapping