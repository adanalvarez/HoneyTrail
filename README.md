# HoneyTrail
<p align="center">
  <img src="HoneyTrail.png" alt="HoneyTrail" width="300" />
</p>
Independently deploy customized honeytokens in AWS to trigger alerts on unauthorized access. It utilizes a dedicated CloudTrail for precise detection and notification specifically for honeytoken activity. 

## Configuration Details

Before deploying HoneyTrail, you must configure the tool according to your specific needs. Below is an example of the shared.auto.tfvars.json.example file included in this repository:

`` 
{
    "enable_s3_event_selector": true,
    "enable_dynamodb_event_selector": false,
    "enable_lambda_event_selector": false,
    "enable_sns": true,
    "destination_email": "example@example.com",
    "source_email": "",
    "vpnapi_key": "",
    "ses_identity": ""
}
``
### Configuration Options

**enable_s3_event_selector:** Set to true to deploy an S3 bucket as a deception service.
**enable_dynamodb_event_selector:** Set to true to deploy a DynamoDB table as a deception service.
**enable_lambda_event_selector:** Set to true to deploy a Lambda function as a deception service.
**enable_sns:** If true, alerts are sent via AWS SNS. This requires no other AWS service.
**destination_email:** Mandatory. The email address where alerts will be sent.
**source_email:** Required if using SES (SNS disabled) for notifications.
**vpnapi_key:** Optional. If using SES (SNS disabled), you can specify a vpnapi.io key to include IP address information in the notifications.
**ses_identities:** Required if using SES (SNS disabled), these are the identities the lambda will use to send the email. 

## Deployment Instructions

- **Clone the Repository:** Start by cloning this repository to your local machine or cloud environment.
- **Review and Modify Configuration:** Create a shared.auto.tfvars.json file using the example, and adjust the settings according to your preferences. Ensure the destination_email is correctly set to receive alerts.
- **Customize Deception Services:** To increase the effectiveness of the deception, you are encouraged to modify the names and data of the services in the honeytoken-dynamodb.tf, honeytoken-lambda.tf, and honeytoken-s3.tf files. Personalizing these details makes the deception more convincing.
- **Initialize Terraform:** Run ``terraform init`` to initialize the Terraform configuration.
- **Apply Terraform Configuration:** Execute ``terraform apply`` to deploy the HoneyTrail services to your AWS environment.
- (Only for SNS) After the terraform apply, the destination_email will receive an email to subscribe to the SNS topic. Confirm the subscription to start receiving alerts. 

## Usage and Alerts

When an attacker interacts with any of the deployed services, a CloudTrail log is created and an alert is triggered.
Alerts will be sent to the destination_email via SNS or SES, depending on your configuration.
