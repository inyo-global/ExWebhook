# ExWebhook

ExWebhook transform any messages from a [brodway](https://github.com/dashbitco/broadway) producer (Kafka, SQS, Google Pub/sub and etc.) in a webhook.  

## Features

* <b>Tenant Aware</b> - Every webhook is tied to a tenant_id, and every message should have a tenant_id field to know wich webhook should be called 
* <b>Batch messages in a single webhook call</b> as a jsonline webhooks (this is optinal)

## Running

The easiest way to getting start with ExWebhook is using docker: 
