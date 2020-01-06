provider "aws" {
  region  = "us-east-1"
}

module "iam" {
  source = "../"
  aws_region = "${var.aws_region}"
  env = "${var.env}"
  aws_account_id = "${var.aws_account_id}"
  ip_whitelist = "${var.ip_whitelist}"
  project = "${var.project}"
}

