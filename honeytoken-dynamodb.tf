resource "aws_dynamodb_table" "honey_s3_dynamodb_table" {
  count = var.enable_dynamodb_event_selector ? 1 : 0

  name           = "CreditCardData"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "CreditCardDataTable"
  }
}

locals {
  dynamodb_event_selectors = var.enable_dynamodb_event_selector ? [{
    name = "Log GetItem and Scan events for my DynamoDB table"
    field_selectors = [
      {
        field  = "eventCategory"
        equals = ["Data"]
      },
      {
        field  = "eventName"
        equals = ["GetItem", "Scan"]
      },
      {
        field       = "resources.ARN"
        equals      = ["${aws_dynamodb_table.honey_s3_dynamodb_table[0].arn}"]
        starts_with = ["${aws_dynamodb_table.honey_s3_dynamodb_table[0].arn}/"]
      },
      {
        field  = "readOnly"
        equals = ["true"]
      },
      {
        field  = "resources.type"
        equals = ["AWS::DynamoDB::Table"]
      }
    ]
  }] : []
}