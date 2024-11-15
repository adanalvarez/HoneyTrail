
locals {
  layer_zip_path    = "layer/layer.zip"
  layer_name        = "requests_layer"
  requirements_path = "${path.root}/layer/requirements.txt"
}

# Create zip file from requirements.txt. Triggers only when the file is updated
resource "null_resource" "build_lambda_layer" {
  triggers = {
    requirements = filesha1(local.requirements_path)
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = "${path.module}/layer/build.sh"
  }
}

# Create lambda layer from zip file
resource "aws_lambda_layer_version" "cloudtrail_insight_lambdas_layer" {
  layer_name          = local.layer_name
  compatible_runtimes = ["python3.11"]
  skip_destroy        = true
  filename            = local.layer_zip_path
  source_code_hash    = filebase64sha256(local.layer_zip_path)
}

module "lambda_function" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "6.5.0"
  function_name = "cloudtrail-insight-alerts"
  description   = "Lambda to enrich cloudtrail events"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  layers = [
    aws_lambda_layer_version.cloudtrail_insight_lambdas_layer.arn
  ]
  source_path = "src/"
  timeout     = 120
  tags = {
    Name = "Cloudtrail-Insight-Alerts"
  }
  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "GetLog",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.trail_s3_bucket.arn}/*"
        ]
      }
    ]
  })

  environment_variables = {
    VPNAPI_KEY        = var.vpnapi_key
    DESTINATION_EMAIL = var.destination_email
    SOURCE_EMAIL      = var.source_email
    SNS               = length(aws_sns_topic.notification_topic) > 0 ? aws_sns_topic.notification_topic[0].arn : ""
  }

}

resource "aws_iam_role_policy" "ses_lambda_policy" {
  count = var.enable_sns ? 0 : 1

  name = "ses_lambda_policy"
  role = module.lambda_function.lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "ses:SendEmail"
      ],
      Resource = var.ses_identities,
      Effect   = "Allow"
    }]
  })
}

resource "aws_lambda_permission" "allows_s3_to_call_cloudtrail_insight_lambda" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.trail_s3_bucket.arn
}


resource "aws_s3_bucket_notification" "lambda_bucket_notification" {
  bucket = aws_s3_bucket.trail_s3_bucket.id

  lambda_function {
    lambda_function_arn = module.lambda_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allows_s3_to_call_cloudtrail_insight_lambda]
}
