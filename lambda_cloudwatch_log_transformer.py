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
                yield strip_timestamp(string_message)

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
    
def strip_timestamp(record_string):
    request_time_loc = record_string.find("request_time")
    if request_time_loc >= 0:
        # 3 because ":"
        # 
        start_of_time_t = request_time_loc + len("request_time") + 3 + len("2023-01-01")
        rec_string_new = record_string[0:start_of_time_t] + ' ' + record_string[start_of_time_t + 1:]
        # Now strip trailing Z, find the next Z
        z_location = rec_string_new.find("Z", request_time_loc)
        if z_location >= 0:
            rec_string_without_z = rec_string_new[0:z_location] + rec_string_new[z_location+1:]
            return rec_string_without_z
    return record_string
