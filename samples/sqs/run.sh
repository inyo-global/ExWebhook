#!bin/bash

docker exec postgres_container psql -U postgres -d postgres -c "INSERT INTO public.webhook (id,tenant_id,url,created_at,is_batch) VALUES ('c3336d02-4d62-406d-ba34-83dfc68bc9a9','foo','https://postman-echo.com/post','2024-06-05 15:46:26.789113',true);"
docker exec postgres_container psql -U postgres -d postgres -c "INSERT INTO public.webhook (id,tenant_id,url,created_at,is_batch) VALUES ('672aa618-e0c1-4788-99ad-b2a5e4e64988','foo','https://postman-echo.com/post','2024-06-05 15:46:26.789113',false);"

docker exec localstack_main aws sqs create-queue --queue-name=sqs-batch --endpoint-url=http://localhost:4566
docker exec localstack_main aws sqs create-queue --queue-name=sqs-single --endpoint-url=http://localhost:4566

docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-batch --message-body '{ "hello":"world1", "tenantId":"foo" }' --endpoint-url=http://localhost:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-batch --message-body '{ "hello":"world2", "tenantId":"foo" }' --endpoint-url=http://localhost:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-batch --message-body '{ "hello":"world3", "tenantId":"foo" }' --endpoint-url=http://localhost:4566

docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-single --message-body '{ "hello":"world1", "tenantId":"foo" }' --endpoint-url=http://localhost:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-single --message-body '{ "hello":"world2", "tenantId":"foo" }' --endpoint-url=http://localhost:4566
docker exec localstack_main aws sqs send-message --queue-url http://localhost:4566/000000000000/sqs-single --message-body '{ "hello":"world3", "tenantId":"foo" }' --endpoint-url=http://localhost:4566


sleep 5s

docker exec postgres_container psql -U postgres -d postgres -c "SELECT id, webhook_id, success, response_status, error, created_at FROM public.webhook_call;"
