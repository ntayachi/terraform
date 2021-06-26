variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Region where to provision resources"
}

variable "ebs_volume_az" {
  type        = string
  default     = "us-east-1a"
  description = "Availability Zone for the EBS volumes"
}

variable "route35_zone" {
  type        = string
  default     = "dev.com"
  description = "Route 53 Hosted Zone"
}