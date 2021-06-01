variable "region" {
  default = "us-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "subnet1_cidr" {
  default = "10.1.0.0/24"
}

variable "subnet2_cidr" {
  default = "10.1.1.0/24"
}

variable "environment_tag" {}

variable "bucket_name_prefix" {
  default = "shivam"
}

locals {
  common_tags = {
    Environment = var.environment_tag
  }

  s3_bucket_name = "${var.bucket_name_prefix}-${var.environment_tag}"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# NETWORKING #
resource "aws_vpc" "shivam_vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.shivam_vpc.id

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-igw" })

}

resource "aws_subnet" "subnet1" {
  cidr_block              = var.subnet1_cidr
  vpc_id                  = aws_vpc.shivam_vpc.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet1" })

}

resource "aws_subnet" "subnet2" {
  cidr_block              = var.subnet2_cidr
  vpc_id                  = aws_vpc.shivam_vpc.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet2" })

}

# ROUTING #
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.shivam_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-rtb" })

}

resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "rta-subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUPS #
resource "aws_security_group" "shivam-sg" {
  name   = "shivam_sg"
  vpc_id = aws_vpc.shivam_vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-sg" })

}

resource "aws_instance" "shivam_day2_instance" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.shivam_day2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.shivam-sg.id]
  subnet_id              = aws_subnet.subnet1.id

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-instance" })
}

# S3 Bucket config#
resource "aws_iam_role" "allow_ec2_instance_s3" {
  name = "allow_ec2_instance_s3"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      },
    ]
  })
}

resource "aws_iam_instance_profile" "shivam_day2_instance_profile" {
  name = "shivam_day2_instance_profile"
  role = aws_iam_role.allow_ec2_instance_s3.name
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_ec2_instance_s3.name

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Action" : [
          "s3:*"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${local.s3_bucket_name}",
          "arn:aws:s3:::${local.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "shivam_s3_bucket" {
  bucket        = local.s3_bucket_name
  acl           = "private"
  force_destroy = true

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-s3-bucket" })

}
