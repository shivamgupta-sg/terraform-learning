provider "aws" {
  region = var.region
}

variable "region" {
  default = us-west-2
}

variable "instance_type" {
  default = "t2.micro"
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

resource "aws_instance" "shivam_instance" {
  ami           = data.aws_ami.aws-linux.id
  instance_type = var.instance_type
   iam_instance_profile = "${aws_iam_instance_profile.shivam_instance_profile.name}"
  tags = {
    Name    = "shivam_instance"
    purpose = "terraform"
  }
}

resource "aws_s3_bucket" "shivam_s3_bucket" {
  bucket = "shivam_s3_bucket"
  acl    = "private"

  tags = {
    Name    = "shivam_s3_bucket"
    purpose = "terraform"
  }
}

resource "aws_iam_role" "shivam_iam_role" {
  name = "shivam_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    purpose = "terraform"
  }
}

resource "aws_iam_role_policy" "shivam_role_policy" {
  name = "shivam_role_policy"
  role = aws_iam_role.shivam_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::shivam_s3_bucket",
                "arn:aws:s3:::shivam_s3_bucket/*"
            ]
        },
    ]
  })
}

resource "aws_iam_instance_profile" "shivam_instance_profile" {
  name = "shivam_instance_profile"
  role = "${aws_iam_role.shivam_iam_role.name}"
}

output "instance_ip" {
  value = aws_instance.instance1.public_ip
}