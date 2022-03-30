#!/bin/bash

endpointUrl=http://${AWS_HOST}:${AWS_PORT}

function configure(){
    aws configure set aws_access_key_id default_access_key
    aws configure set aws_secret_access_key default_secret_key
    aws configure set region sa-east-1
}

function createTable() {
    printf 'Creating order book table'
    aws dynamodb --endpoint-url=${endpointUrl} create-table --table-name order-book-operation \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
        AttributeName=operationType,AttributeType=S \
        AttributeName=operationStatus,AttributeType=S \
    --key-schema \
        AttributeName=operationType,KeyType=HASH \
        AttributeName=id,KeyType=RANGE \
    --global-secondary-indexes  \
    "[
            {
                \"IndexName\": \"operationStatusAndOperationTypeIndex\",
                \"KeySchema\": [
                    {\"AttributeName\":\"operationStatus\",\"KeyType\":\"HASH\"},
                    {\"AttributeName\":\"operationType\",\"KeyType\":\"RANGE\"}
                ],
                \"Projection\": {
                    \"ProjectionType\":\"ALL\"
                },
                \"ProvisionedThroughput\": {
                    \"ReadCapacityUnits\": 10,
                    \"WriteCapacityUnits\": 5
                }
            }
        ]" \
    --stream-specification StreamEnabled=TRUE,StreamViewType=NEW_AND_OLD_IMAGES \
    --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=5
}

configure
createTable

