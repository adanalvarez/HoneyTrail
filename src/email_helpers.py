import boto3
from botocore.exceptions import ClientError
import logging
import os


def generate_email_html(style, sections):
    """Generates an HTML email template with Cloudtrial information, IP information, and CloudTrail information."""
    combined_sections = "".join(sections)
    return f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Honeytoken CloudTrail Alert</title>
            {style}
        </head>
        <body>
        <div class="container">
            <div class="header">Honeytoken CloudTrail Alert</div>
            {combined_sections}
        </div>
        </body>
        </html>
    """


def ses_send_email(html_content, records, source_email, destination_email):
    """Sends an email using AWS SES."""
    ses_client = boto3.client("ses")
    finding_title = f'{records[0]["eventName"]} - {records[0]["eventSource"]}'
    if not source_email or not destination_email:
        logging.error(
            "Source and destination emails are required. Please set them as environment variables."
        )
        return

    subject = f"[AWS Honeytoken CloudTrail Alert] {finding_title}"

    try:
        response = ses_client.send_email(
            Source=source_email,
            Destination={"ToAddresses": [destination_email]},
            Message={
                "Subject": {"Data": subject},
                "Body": {"Html": {"Data": html_content}},
            },
        )
        logging.info(f"Email sent successfully: {response['MessageId']}")
    except ClientError as e:
        logging.error(f"Error sending email: {e.response['Error']['Message']}")

def sns_send_email(sns_topic, records):
    """Sends a messaje to an SNS topic."""
    sns_client = boto3.client("sns")
    topic_arn = sns_topic
    finding_title = f'{records[0]["eventName"]} - {records[0]["eventSource"]}'
    message = 'Interaction with honeytoken\n\n'
    message = message + f'Event: {records[0]["eventName"]}\n'
    message = message + f'Event Source: {records[0]["eventSource"]}\n\n'
    message = message + f'User Identity: {records[0]["userIdentity"]}\n\n'
    message = message + f'Resources: {records[0]["resources"]}\n\n'
    subject = f"[AWS Honeytoken CloudTrail Alert] {finding_title}"

    try:
        response = sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=subject[:100] 
        )
        logging.info(f"Notification punlished successfully.")
    except ClientError as e:
        logging.error(f"Error publishing notification: {e.response['Error']['Message']}")

