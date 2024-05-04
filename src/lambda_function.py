import json
import boto3
import os
import gzip
from io import BytesIO
from styles import generate_style
from cloudtrail_helpers import generate_cloudtrail_information_section
from email_helpers import generate_email_html, sns_send_email, ses_send_email
from ip_helpers import get_ip_information_section

import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

def lambda_handler(event, context):
    s3_client = boto3.client('s3')
    source_email = os.environ.get("SOURCE_EMAIL")
    destination_email = os.environ.get("DESTINATION_EMAIL")
    api_key = os.environ.get("VPNAPI_KEY")
    sns_topic = os.environ.get("SNS")

    sections = []
    style = generate_style(event)

    # Assuming the event is from S3
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
       
        # Get the gzipped file from S3
        response = s3_client.get_object(Bucket=bucket, Key=key)
        gzipped_file = response['Body'].read()
        
        # Decompress the gzipped file
        with gzip.GzipFile(fileobj=BytesIO(gzipped_file)) as gzipfile:
            file_content = gzipfile.read()
        
        # Convert file content from bytes to string
        decoded_content = file_content.decode('utf-8')
        try:
            json_content = json.loads(decoded_content)
        except json.JSONDecodeError as error:
            print(f"Error decoding JSON: {error}")
            # Handle the error appropriately
            return

        cloudtrail_information = generate_cloudtrail_information_section(json_content)
        sections.append(cloudtrail_information)
        ip_information, ip_address_v4 = get_ip_information_section(json_content, api_key)
        sections.append(ip_information)
        email_html = generate_email_html(style, sections)
        if sns_topic != "":
            sns_send_email(sns_topic, json_content["Records"])
        else:
            ses_send_email(
                email_html,
                json_content["Records"],
                source_email,
                destination_email,
            )