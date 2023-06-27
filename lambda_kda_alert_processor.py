from __future__ import print_function
import json
import os
import boto3
import base64
from botocore.exceptions import ClientError

sqs_name = os.environ['SQS_OUTPUT_STREAM']

def processRecords(records):
    for r in records:
        data = base64.b64decode(r['kinesis']['data']).decode("utf-8")
        y = json.loads(data)
        yield data

def lambda_handler(event, context):
    records = list(processRecords(event['Records']))
    for r in records:
        try:   
            sqs = boto3.client('sqs')  #client is required to interact with 
            sqs.send_message(
                QueueUrl=sqs_name,
                MessageBody=r)

        except ClientError:
            raise

    return {"statusCode":200, "body":"Successfully posted to SQS"}
