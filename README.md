# odp-tf-aws-ref-arch-iam

## Overview <a name="s1"></a>

The `odp-tf-aws-ref-arch-iam`  module is used to configure X resources.

## Table of Contents <a name="s2"></a>

* [Overview](#s1)
* [Table of Conents](#s2)
* [Module Contents](#s3)
* [Module Variables](#s4)
* [Module Setup](#s5)
* [Resources Created](#s6)


## Module Contents <a name="s3"></a>


| Folder / File      |  Description  |
|---          |---    |
| main.tf   |   Main Terraform code |
| variables.tf   |   Required Variables |
| output.tf   |   Output variables |
| example/      |  Example directory that contains the configuration necessary to deploy the project. |
| .circleci   | CI Pipeline code for validating module.  Requires working example in `example` directory. |


## Module Variables  <a name="s4"></a>


### Inputs

The following variables need to be set either by setting proper environment variables or editing the variables.tf file:

| Variable      |  Type  |  Description  |
|---          |---        |---  | 
| aws_region  |  string |   Default region for region specific settings. |
| env         |  string | Environment used in naming resources |
| aws_account_id | string | AWS Account to configure |
| ip_whitelist | string | IP address list ( CIDR ) to allow remote access into the accoutn
| project| string | Project name to that makes up part of prefix for resources. |


variable "project" {
  description = "Project name"
}


### Outputs

The following variables need to be set either by setting proper environment variables or editing the variables.tf file:

| Variable      |  Type  |  Description  |
|---          |---        |---  | 
|   |   |    |

## Module Setup <a name="s5"></a>


### Required IAM


### Example


```
provider "aws" {
  region  = "us-east-1"
}

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
  default = "xxxxxx"
}

variable "ip_whitelist" {
  description = "source IP whitelist"
  default = "10.1.1.0/24"
}

variable "project" {
  description = "Project name"
  default = "odp-ref-arch"
}

module "iam" {
  source = "../"
  aws_region = "${var.aws_region}"
  env = "${var.env}"
  aws_account_id = "${var.aws_account_id}"
  ip_whitelist = "${var.ip_whitelist}"
  project = "${var.project}"
}

```

## Resources Created <a name="s6"></a>

### Policies

* force_mfa
* remote_access
* assume_iam_admin_operations
* assume_full_admin_management
* incident_response_secops
* iam_admin_operations
* full_admin_management


***NOTE:*** All resources are prefixed with the value assigned to the variable project.  <b>Example:</b>`myresource` becomes `${project}-myresource`

#### Password Policy

This module sets the default password policy.

### Roles

***NOTE:*** All resources are prefixed with the value assigned to the variable project.  <b>Example:</b>`myresource` becomes `${project}-myresource`

* management_org_admin
* full_admin_management
* iam_admin_operations
* config
* cloudwatch_delivery


### Groups

***NOTE:*** All resources are prefixed with the value assigned to the variable project.  <b>Example:</b>`myresource` becomes `${project}-myresource`

* devsecops
* default
* security_assessment
* security_operations
* finance
* user_management
* full_admin
* incident_response

