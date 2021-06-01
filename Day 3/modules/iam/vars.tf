# variable "s3_bucket_name" {}

locals {
  common_tags = {
    Environment = var.environment_tag
  }

  s3_bucket_name = "${var.bucket_name_prefix}-${var.environment_tag}"
}

variable "environment_tag" {}

variable "bucket_name_prefix" {
  default = "shivam"
}