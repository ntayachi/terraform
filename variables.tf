variable "aws_region" {
    type        = string
    default     = "us-east-2"
    description = "Region where to provision Lambda"
}

variable "lambda_name" {
    type        = string
    default     = "probe"
    description = "Lambda function name"
}