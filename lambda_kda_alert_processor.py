from __future__ import print_function
import json
import os
import boto3
import base64
from botocore.exceptions import ClientError

sqs_name = os.environ['SQS_OUTPUT_STREAM']
block_period_seconds = 30
sqs = boto3.client('sqs')  #client is required to interact with 

def processRecords(records):
    for r in records:
        data = base64.b64decode(r['kinesis']['data']).decode("utf-8")
        y = json.loads(data)
        yield data

def lambda_handler(event, context):
    records = list(processRecords(event['Records']))
    for r in records:
        try:              
            sqs.send_message(
                QueueUrl=sqs_name,
                MessageBody=r)
            print("Sent sqs message to block")
            
            jsonobj = json.loads(r)
            jsonobj["alertTypeName"] = "UnblockIP"
            sqs.send_message(QueueUrl=sqs_name, MessageBody=json.dumps(jsonobj), DelaySeconds=block_period_seconds)
            print("Sent sqs message to unblock with delay of " + block_period_seconds)
            
        except ClientError:
            raise

    return {"statusCode":200, "body":"Successfully posted to SQS"}
