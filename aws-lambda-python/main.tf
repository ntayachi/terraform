provider "aws" {
  region = var.aws_region
}

data "external" "zip_package" {
  program = [ "${path.root}/zip_package.sh" ]
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      identifiers = [ "lambda.amazonaws.com" ]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "probe_iam" {
  name               = "probe_iam"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

resource "aws_lambda_function" "lambda_probe" {
  function_name    = var.lambda_name
  filename         = data.external.zip_package.result.package
  source_code_hash = filebase64sha256(data.external.zip_package.result.package)
  role             = aws_iam_role.probe_iam.arn
  handler          = "probe.lambda_handler"
  runtime          = "python3.8"
  timeout          = 20
}

resource "aws_iam_role_policy_attachment" "logs_policy" {
  role       = aws_iam_role.probe_iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "probe_log_group" {
  name = "/aws/lambda/${var.lambda_name}"
}

resource "aws_cloudwatch_event_rule" "crontab_every_5min" {
  name                = "probe_crontab"
  schedule_expression = "cron(0/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "run_lambda_every_5min" {
  rule = aws_cloudwatch_event_rule.crontab_every_5min.name
  arn  = aws_lambda_function.lambda_probe.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_probe.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.crontab_every_5min.arn
}

resource "aws_sns_topic" "probe_logs" {
  name         = "probe_logs"
  display_name = "Lambda probe logs"
}

resource "aws_sns_topic_subscription" "probe_logs_email_sub" {
  topic_arn = aws_sns_topic.probe_logs.arn
  protocol  = "email"
  endpoint  = "tayachi.nafaa@gmail.com"
}

resource "aws_iam_policy" "sns_topic_policy" {
  name        = "sns_topic_policy"
  description = "SNS publish policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SnsPolicy",
      "Effect": "Allow",
      "Action": [ 
        "sns:Publish"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sns_policy_attachment" {
  role       = aws_iam_role.probe_iam.name
  policy_arn = aws_iam_policy.sns_topic_policy.arn
}

resource "aws_lambda_function_event_invoke_config" "sns_destination" {
  function_name = aws_lambda_function.lambda_probe.function_name
  destination_config {
    on_failure {
      destination = aws_sns_topic.probe_logs.arn
    }
    on_success {
      destination = aws_sns_topic.probe_logs.arn
    }
  }
}