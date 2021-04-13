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