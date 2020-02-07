variable "aws_region" {
  type = string
  description = "Default region used by some modules"
  default = "us-east-1"
}

variable "env" {
  description = "AWS region to launch servers."
  default     = "sandbox"
}

variable "aws_account_id" {
  description = "aws account ID"
}

# place holder for cross account access
variable "cross_aws_account_id" {
  description = "aws account ID"
}

variable "ip_whitelist" {
  description = "source IP whitelist"
}

variable "project" {
  description = "Project name"
}