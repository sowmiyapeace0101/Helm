provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my-ec2" {
  ami                     = "ami-0cd59ecaf368e5ccf"
  instance_type           = "t2.micro"
  key_name = "dpp"
 
 vpc_security_group_ids = [aws_security_group.demo-sg.id]
  subnet_id = aws_subnet.my-subnet-1.id

for_each = toset(["Jenikns-Slave"])   
tags = {
Name = "${each.key}"
}
}

# VPC Block

resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/23"
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
  }
}

# SUBNET Block(1)

resource "aws_subnet" "my-subnet-1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "my-subnet-1"
  }
}



resource "aws_subnet" "my-subnet-2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  

  tags = {
    Name = "my-subnet-2"
  }
}
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow 8080 and 80"
  vpc_id      = aws_vpc.my-vpc.id

ingress {
description = "Shh access"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
description = "Http"
from_port = 8080
to_port = 8080
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
}

  
  tags = {
    Name = "demo-sg"
  }
}
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-igw"
  }
}
resource "aws_route_table" "my-rt" {
vpc_id = aws_vpc.my-vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.my-igw.id
}
}
resource "aws_route_table_association" "rt-subnet-01" {
subnet_id = aws_subnet.my-subnet-1.id
route_table_id = aws_route_table.my-rt.id
}
resource "aws_route_table_association" "rt-subnet-02" {
subnet_id = aws_subnet.my-subnet-2.id
route_table_id = aws_route_table.my-rt.id
}