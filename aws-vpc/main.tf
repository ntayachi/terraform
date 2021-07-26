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
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch =  true

  tags = {
    "Name" = "myPublicSubnet"
  }
}

resource "aws_subnet" "myPrivateSubnet" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    "Name" = "myPrivateSubnet"
  }
}

resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    "Name" = "myIGW"
  }
}

resource "aws_route_table" "myPublicRouteTable" {
  vpc_id = aws_vpc.myVPC.id
  
  tags = {
    "Name" = "myPublicRouteTable"
  }
}

resource "aws_route" "internetRoute" {
  route_table_id         = aws_route_table.myPublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIGW.id
}

resource "aws_route_table_association" "publicSubnetAssociation" {
  subnet_id      = aws_subnet.myPublicSubnet.id
  route_table_id = aws_route_table.myPublicRouteTable.id
}

resource "aws_security_group" "mySecurityGroup" {
  name        = "mySecurityGroup"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.myVPC.id
}

resource "aws_security_group_rule" "sshInboundRule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mySecurityGroup.id
}

resource "aws_security_group_rule" "httpInboundRule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mySecurityGroup.id
}

resource "aws_network_interface" "myPublicNetworkInterface" {
  subnet_id = aws_subnet.myPublicSubnet.id

  tags = {
    "Name" = "myPublicNetworkInterface"
  }
}

resource "aws_network_interface" "myPrivateNetwokInterface" {
  subnet_id       = aws_subnet.myPrivateSubnet.id
  security_groups = [aws_security_group.mySecurityGroup.id]

  tags = {
    "Name" = "myPrivateNetwokInterface"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["Amazon Linux*"]
  }
}

resource "aws_instance" "myPublicInstance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.myPublicNetworkInterface.id
    device_index         = 0
  }


  tags = {
    "Name" = "myPublicInstance"
  }
}

resource "aws_instance" "myPrivateInstance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.myPrivateNetwokInterface.id
    device_index         = 0
  }

  tags = {
    "Name" = "myPrivateInstance"
  }
}