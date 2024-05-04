resource "aws_iam_role" "honey_go_lambda_execution_role" {
  count = var.enable_lambda_event_selector ? 1 : 0

  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy" "honey_go_lambda_policy" {
  count = var.enable_lambda_event_selector ? 1 : 0

  name = "lambda_policy"
  role = aws_iam_role.honey_go_lambda_execution_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "arn:aws:logs:*:*:*",
      Effect   = "Allow"
    }]
  })
}

resource "aws_lambda_function" "honey_go_lambda" {
  count = var.enable_lambda_event_selector ? 1 : 0

  function_name = "GetAccessKeyForBackups"
  handler       = "main"
  role          = aws_iam_role.honey_go_lambda_execution_role[0].arn
  runtime       = "provided.al2023"

  filename         = "honeytoken-lambda-src/lambda-handler.zip"
  source_code_hash = filebase64sha256("honeytoken-lambda-src/lambda-handler.zip")
}

locals {
  lambda_event_selectors = var.enable_lambda_event_selector ? [{
    name = "Log Invoke events for my Lambda"
    field_selectors = [
      {
        field  = "eventCategory"
        equals = ["Data"]
      },
      {
        field  = "resources.ARN"
        equals = ["${aws_lambda_function.honey_go_lambda[0].arn}"]
      },
      {
        field  = "resources.type"
        equals = ["AWS::Lambda::Function"]
      }
    ]
  }] : []
}