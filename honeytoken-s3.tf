resource "aws_s3_bucket" "honey_s3_bucket" {
  count  = var.enable_s3_event_selector ? 1 : 0
  bucket = "data-bucket-${random_pet.pet.id}-${random_id.id.hex}"
}

resource "aws_s3_object" "object" {
  count  = var.enable_s3_event_selector ? 1 : 0
  bucket = aws_s3_bucket.honey_s3_bucket[0].id
  key    = "users_data.csv"
  source = "users_data.csv"

  etag = filemd5("users_data.csv")
}

locals {
  s3_event_selectors = var.enable_s3_event_selector ? [
    {
      name = "Log GetObject events for my S3 bucket"
      field_selectors = [
        {
          field  = "eventCategory"
          equals = ["Data"]
        },
        {
          field  = "eventName"
          equals = ["GetObject"]
        },
        {
          field       = "resources.ARN"
          starts_with = ["${aws_s3_bucket.honey_s3_bucket[0].arn}/"]
        },
        {
          field  = "readOnly"
          equals = ["true"]
        },
        {
          field  = "resources.type"
          equals = ["AWS::S3::Object"]
        }
      ]
    }
  ] : []
}