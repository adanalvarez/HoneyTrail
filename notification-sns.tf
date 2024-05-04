resource "aws_sns_topic" "notification_topic" {
  count = var.enable_sns ? 1 : 0
  name  = "s3-event-notification-topic"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = var.enable_sns ? 1 : 0
  statement {
    sid       = "1"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.notification_topic[0].arn]  

    condition {
      test     = "ArnLike" 
      variable = "aws:SourceArn"
      values   = [module.lambda_function.lambda_function_arn]  
    }

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sns_lambda_policy" {
  count = var.enable_sns ? 1 : 0
  statement {
    sid       = "1"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.notification_topic[0].arn]  
  }
}

resource "aws_iam_role_policy" "sns_lambda_policy" {
  count = var.enable_sns ? 1 : 0

  name = "sns_lambda_policy"
  role = module.lambda_function.lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "sns:Publish"
      ],
      Resource = aws_sns_topic.notification_topic[0].arn,
      Effect   = "Allow"
    }]
  })
}

resource "aws_sns_topic_policy" "default" {
  count = var.enable_sns ? 1 : 0

  arn    = aws_sns_topic.notification_topic[0].arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

resource "aws_sns_topic_subscription" "notification_topic_email_subscription" {
  count = var.enable_sns ? 1 : 0

  topic_arn = aws_sns_topic.notification_topic[0].arn
  protocol  = "email"
  endpoint  = var.destination_email
}