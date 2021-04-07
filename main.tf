provider "aws" {
    region = var.aws_region
}

data "aws_iam_policy_document" "policy" {
    statement {
      sid     = ""
      effect  = "Allow"
      
      principals {
          identifiers = [ "lambda.amzonaws.com" ]
          type        = "Service"
      }

      actions = [ "sts:AssumeRole" ]
    }
}

resource "aws_iam_role" "probe_iam" {
    name = "probe_iam"
    assume_role_policy = data.aws_iam_policy_document.policy.json
}