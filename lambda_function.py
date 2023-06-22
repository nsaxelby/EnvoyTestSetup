from __future__ import print_function
import calendar
import random
import time
import json
import os
import gzip
import base64
import boto3
from botocore.exceptions import ClientError

stream_name = os.environ['KINESIS_STREAM']
kinesis_client = boto3.client('kinesis', region_name='eu-west-1')

def processRecords(records):
    for r in records:
        data = loadJsonGzipBase64(r['kinesis']['data'])
        # CONTROL_MESSAGE are sent by CWL to check if the subscription is reachable.
        # They do not contain actual data.
        if data['messageType'] == 'DATA_MESSAGE':
            for log_event in data['logEvents']:
                string_message = log_event['message']
                yield string_message

def loadJsonGzipBase64(base64Data):
    return json.loads(gzip.decompress(base64.b64decode(base64Data)))

def lambda_handler(event, context):
    records = list(processRecords(event['Records']))
    for r in records:
        try:
            put_response = kinesis_client.put_record(
                StreamARN=stream_name,
                Data=r,
                PartitionKey='1')
        except ClientError:
            raise

    return {"statusCode":200, "body":"Successfully posted"}