variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Region where to provision resources"
}

variable "tag" {
    type        = string
    default     = "latest"
    description = "The ECR image tag"
}