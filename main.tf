
# PROVIDER

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "tls" {}

provider "local" {}



# TLS PRIVATE KEY

resource "tls_private_key" "strapi_private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# AWS KEY PAIR

resource "aws_key_pair" "strapi_keypair" {
  key_name   = "strapi-key"
  public_key = tls_private_key.strapi_private.public_key_openssh
}


# SAVE PRIVATE KEY LOCALLY

resource "local_file" "strapi_private_key" {
  filename        = "strapi-key.pem"
  content         = tls_private_key.strapi_private.private_key_pem
  file_permission = "0400"
}


# VPC

resource "aws_vpc" "strapi_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "strapi-vpc"
  }
}


# SUBNET

resource "aws_subnet" "strapi_subnet" {
  vpc_id                  = aws_vpc.strapi_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az

  tags = {
    Name = "strapi-public-subnet"
  }
}


# INTERNET GATEWAY

resource "aws_internet_gateway" "strapi_igw" {
  vpc_id = aws_vpc.strapi_vpc.id

  tags = {
    Name = "strapi-igw"
  }
}


# ROUTE TABLE

resource "aws_route_table" "strapi_rt" {
  vpc_id = aws_vpc.strapi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.strapi_igw.id
  }

  tags = {
    Name = "strapi-route-table"
  }
}


# ROUTE TABLE ASSOCIATION

resource "aws_route_table_association" "strapi_rta" {
  subnet_id      = aws_subnet.strapi_subnet.id
  route_table_id = aws_route_table.strapi_rt.id
}


# SECURITY GROUP

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow SSH and Strapi"
  vpc_id      = aws_vpc.strapi_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Strapi Port"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-sg"
  }
}


# EC2 INSTANCE

resource "aws_instance" "strapi_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.strapi_subnet.id
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
  key_name               = aws_key_pair.strapi_keypair.key_name

  user_data = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "strapi-ec2"
  }
}
