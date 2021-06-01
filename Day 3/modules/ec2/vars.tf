variable "iam_instance_profile_name" {}

locals {
  common_tags = {
    Environment = var.environment_tag
  }

  s3_bucket_name = "${var.bucket_name_prefix}-${var.environment_tag}"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "public_subnet_id"{}

variable "vpc_sg_id" {}

variable "environment_tag" {}

variable "bucket_name_prefix" {
  default = "shivam"
}