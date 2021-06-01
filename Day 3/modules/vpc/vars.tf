locals {
  common_tags = {
    Environment = var.environment_tag
  }

  s3_bucket_name = "${var.bucket_name_prefix}-${var.environment_tag}"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.1.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.1.1.0/24"
}

variable "environment_tag" {}

variable "bucket_name_prefix" {
  default = "shivam"
}