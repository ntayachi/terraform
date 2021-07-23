provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    "Name" = "myVPC"
  }
}

resource "aws_subnet" "myPublicSubnet" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch =  true

  tags = {
    "Name" = "myPublicSubnet"
  }
}

resource "aws_subnet" "myPrivateSubnet" {
  vpc_id = aws_vpc.myVPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    "Name" = "myPrivateSubnet"
  }
}