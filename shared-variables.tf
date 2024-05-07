
variable "destination_email" {}
variable "enable_s3_event_selector" {}
variable "enable_dynamodb_event_selector" {}
variable "enable_lambda_event_selector" {}
variable "enable_sns" {}
# For enriched emails using SES
variable "ses_identities" {}
variable "source_email" {}
variable "vpnapi_key" {}