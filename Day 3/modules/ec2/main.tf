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

resource "aws_instance" "shivam_day2_instance" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = var.instance_type
  iam_instance_profile   = var.iam_instance_profile_name
  vpc_security_group_ids = [var.vpc_sg_id]
  subnet_id              = var.public_subnet_id

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-instance" })
}