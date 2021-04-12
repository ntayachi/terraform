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
          identifiers = [ "lambda.amzonaws.com" ]
          type        = "Service"
      }
    }
}

resource "aws_iam_role" "probe_iam" {
    name               = "probe_iam"
    assume_role_policy = data.aws_iam_policy_document.policy.json
}