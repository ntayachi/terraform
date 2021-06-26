provider "aws" {
  region = var.aws_region
}

locals {
  volumes = toset([
    "xvdf",
    "xvdg"
  ])
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["Amazon Linux*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
}

resource "aws_ebs_volume" "ebs_volumes" {
  for_each = local.volumes
  
  availability_zone = var.ebs_volume_az
  size              = 20
}

resource "aws_volume_attachment" "name" {
  for_each = local.volumes

  device_name = "/dev/${each.key}"
  volume_id   = aws_ebs_volume.ebs_volumes["${each.key}"].id
  instance_id = aws_instance.web_server.id
}

data "aws_route53_zone" "dev_zone" {
  name = var.route35_zone
}

resource "aws_route53_record" "dev_record" {
  zone_id = data.aws_route53_zone.dev_zone.zone_id
  name = "www.web-server.${data.aws_route53_zone.dev_zone.name}"
  type = "A"
  ttl = "300"
  records = [ "123.4.5.67" ]
}