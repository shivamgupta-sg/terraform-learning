resource "aws_s3_bucket" "shivam_s3_bucket" {
  bucket        = local.s3_bucket_name
  acl           = "private"
  force_destroy = true

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-s3-bucket" })

}