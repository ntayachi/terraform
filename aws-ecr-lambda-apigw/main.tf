provider "aws" {
    region = var.aws_region
}

resource "aws_ecr_repository" "ecr_repo" {
  name                 = "my-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_image" "my_image" {
  repository_name = aws_ecr_repository.ecr_repo.name
  image_tag       = var.tag
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "my_iam_role" {
  name               = "my-role"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

resource "aws_lambda_function" "my_lambda" {
  function_name    = "my-lambda-function"
  package_type     = "Image"
  image_uri        = data.aws_ecr_image.my_image.id
  role             = aws_iam_role.my_iam_role.arn
  timeout          = 60
}

resource "aws_iam_role_policy_attachment" "logs_policy" {
  role       = aws_iam_role.my_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_api_gateway_rest_api" "my_gateway" {
    name = "my-api-gateway"
}

resource "aws_api_gateway_resource" "my_endpoint" {
  rest_api_id = aws_api_gateway_rest_api.my_gateway.id
  parent_id   = aws_api_gateway_rest_api.my_gateway.root_resource_id
  path_part   = "myendpoint"
}

resource "aws_api_gateway_method" "post_method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.my_endpoint.id
  rest_api_id   = aws_api_gateway_rest_api.my_gateway.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_gateway.id
  resource_id             = aws_api_gateway_resource.my_endpoint.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_gateway.execution_arn}/*/POST/myendpoint"
}