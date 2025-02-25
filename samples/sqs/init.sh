#!bin/bash

docker exec localstack_main aws sqs create-queue --queue-name=sqs-demo --endpoint-url=http://${LOCALSTACK_HOST:-localhost}:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-demo --message-body '{ "hello":"world", "tenantId":"1" }' --endpoint-url=http://${LOCALSTACK_HOST:-localhost}:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-demo --message-body '{ "hello":"world", "tenantId":"1" }' --endpoint-url=http://${LOCALSTACK_HOST:-localhost}:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-demo --message-body '{ "hello":"world", "tenantId":"1" }' --endpoint-url=http://${LOCALSTACK_HOST:-localhost}:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-demo --message-body '{ "hello":"world", "tenantId":"1" }' --endpoint-url=http://${LOCALSTACK_HOST:-localhost}:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-demo --message-body '{ "hello":"world", "tenantId":"1" }' --endpoint-url=http://${LOCALSTACK_HOST:-localhost}:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-demo --message-body '{ "hello":"world", "tenantId":"1" }' --endpoint-url=http://${LOCALSTACK_HOST:-localhost}:4566