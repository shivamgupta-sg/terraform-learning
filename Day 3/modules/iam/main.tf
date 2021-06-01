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

resource "aws_iam_instance_profile" "shivam_instance_profile" {
  name = "shivam_instance_profile"
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

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.shivam_instance_profile.name
}