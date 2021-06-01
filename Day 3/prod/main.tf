provider "aws" {
  region = "us-west-2"
}

variable "bucket_name_prefix" {
  default = "shivam"
}

variable "environment_tag" {}

module "ec2_mod" {
  source                    = "../modules/ec2"
  environment_tag           = var.environment_tag
  iam_instance_profile_name = module.iam_mod.iam_instance_profile_name
  public_subnet_id          = module.vpc_mod.public_subnet_id
  vpc_sg_id                 = module.vpc_mod.vpc_sg_id
}

module "iam_mod" {
  source          = "../modules/iam"
  environment_tag = var.environment_tag
}

module "s3_mod" {
  source          = "../modules/s3"
  environment_tag = var.environment_tag
}

module "vpc_mod" {
  source          = "../modules/vpc"
  environment_tag = var.environment_tag
}
