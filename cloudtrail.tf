locals {
  trail_name          = "trail-${random_pet.pet.id}-${random_id.id.hex}"
  all_event_selectors = concat(local.s3_event_selectors, local.dynamodb_event_selectors, local.lambda_event_selectors)
}

resource "aws_s3_bucket" "trail_s3_bucket" {
  bucket        = "bucket-trail-${random_pet.pet.id}-${random_id.id.hex}"
  force_destroy = true
}

data "aws_iam_policy_document" "trail_s3_bucket_policy_document" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail_s3_bucket.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail_s3_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "trail_s3_bucket_policy" {
  bucket = aws_s3_bucket.trail_s3_bucket.id
  policy = data.aws_iam_policy_document.trail_s3_bucket_policy_document.json
}

resource "aws_cloudtrail" "honey_trail" {
  depends_on = [aws_s3_bucket_policy.trail_s3_bucket_policy]

  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.trail_s3_bucket.id
  include_global_service_events = false
  dynamic "advanced_event_selector" {
    for_each = local.all_event_selectors
    content {
      name = advanced_event_selector.value.name

      dynamic "field_selector" {
        for_each = advanced_event_selector.value.field_selectors
        content {
          field       = field_selector.value.field
          equals      = lookup(field_selector.value, "equals", null)
          starts_with = lookup(field_selector.value, "starts_with", null)
        }
      }
    }
  }
}