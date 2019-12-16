provider "aws" {
  region     = var.aws_region
}

# --------------------
# Password Policy

## IAM password  Policy
resource "aws_iam_account_password_policy" "grace_iam_password_policy" {
  minimum_password_length        = 16
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 10
}

# --------------------
# Users




## User designated for automated deployments

resource "aws_iam_user" "user_deployer" {
  name = "${project}-deployer"
}

# --------------------
# Groups

resource "aws_iam_group" "devsecops" {
  name = "${project}-devsecops"
}

resource "aws_iam_group" "default" {
  name = "${project}-default"
}

resource "aws_iam_group" "security_assessment" {
  name = "${project}-security-assessment"
}

resource "aws_iam_group" "security_operations" {
  name = "${project}-security-operations"
}

resource "aws_iam_group" "finance" {
  name = "${project}-finance"
}

resource "aws_iam_group" "user_management" {
  name = "${project}-user-management"
}

resource "aws_iam_group" "full_admin" {
  name = "${project}-full-admin"
}

resource "aws_iam_group" "incident_response" {
  name = "${project}-incident-response"
}


# --------------------
# Roles

## grace mgmt billing role

resource "aws_iam_role" "billing_management" {
  name = "${project}-billing-management"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

## grace mgmt org admin role
resource "aws_iam_role" "management_org_admin" {
  name = "${project}-management-org-admin"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

## grace mgmt full admin role
resource "aws_iam_role" "full_admin_management" {
  name = "${project}-full-admin-management"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

## grace OPs admin role
resource "aws_iam_role" "iam_admin_operations" {
  name = "${project}-iam-admin-operations"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

## IAM ROLE for AWS Config
resource "aws_iam_role" "config" {
  name = "${project}-config"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY

}

# --------------------
# Policies


data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

## policy for MFA
resource "aws_iam_policy" "force_mfa" {
  name        = "${project}-force-mfa"
  path        = "/"
  description = "Forces iam users to set MFA to access services"
  policy      = file("${path.module}/files/force_mfa.json")
}


## region restriction for deployer

resource "aws_iam_policy" "restrict_region_ci" {
  name        = "${project}-restrict-region-ci"
  path        = "/"
  description = "limit PowerUserAccess used for CI to region us-east-1."
  policy      = file("${path.module}/files/restrict_region_ci.json")
}



## Policy for the deployment user

resource "aws_iam_policy" "user_deployer" {
  name        = "${project}-user-deployer"
  path        = "/"
  description = "User policy for user_deployer."
  policy      = file("${path.module}/files/user_deployer.json")
}



## Policy for RemoteSourceIPRestriction
resource "aws_iam_policy" "remote_access" {
  name        = "${project}-remote-access"
  path        = "/"
  description = "Restrict remote access to whitelisted source IPs"
  policy      = file("${path.module}/files/remote_access.json")
}

resource "aws_iam_policy" "assume_billing_management" {
  name        = "${project}-assume-billing-management"
  description = "Allow access to assume role for view only access to billing and usage"
  path        = "/"
  policy      = file("${path.module}/files/assume_billing_management.json")

}


## billing policy
resource "aws_iam_policy" "billing_management" {
  name        = "${project}-billing-management"
  description = "Policy to allow access to view Billing and Usage data "
  path        = "/"
  policy      = file("${path.module}/files/billing_management.json")
}

## assume admin policy
resource "aws_iam_policy" "assume_iam_admin_operations" {
  name        = "${project}-assume-iam-admin-ops"
  description = "Switch role to manage IAM "
  path        = "/"
  policy      = file("${path.module}/files/assume_iam_admin_operations.json")  
}

## assume fulladmin policy
resource "aws_iam_policy" "assume_full_admin_management" {
  name        = "${project}-assume-full-admin-management"
  description = "Break glass - switch role to gain full admin rights and Organizations access"
  path        = "/"
  policy      = file("${path.module}/files/assume_full_admin_management.json")  
}

## Grace secops IR policy
resource "aws_iam_policy" "incident_response_secops" {
  name        = "${project}-incident-response-secops"
  description = "SecOps incident response policy"
  path        = "/"
  policy      = file("${path.module}/files/incident_response_secops.json")  
}

## grace ops admin policy
resource "aws_iam_policy" "iam_admin_operations" {
  name        = "${project}-iam-admin-operations"
  description = "Policy to allow full access to manage IAM resources"
  path        = "/"
  policy      = file("${path.module}/files/iam_admin_operations.json")
}


## grace mgmt full admin policy
resource "aws_iam_policy" "full_admin_management" {
  name        = "${project}-full-admin-management"
  description = "Policy to allow full admin access"
  path        = "/"
  policy      = file("${path.module}/files/full_admin_management.json")
}



# --------------------
# Policy Attachements


# Users - Policy Attachements 

## Policy for the deployment user 

resource "aws_iam_user_policy_attachment" "user_deployer" {
  user       = "${aws_iam_user.user_deployer.name}"
  policy_arn = "${aws_iam_policy.user_deployer.arn}"
}

## circle CI policy
resource "aws_iam_user_policy_attachment" "restrict_region_ci" {
  user       = aws_iam_user.user_deployer.name
  policy_arn = aws_iam_policy.restrict_region_ci.arn
}

# Groups - Policy Attachements 

## billing assume
resource "aws_iam_group_policy_attachment" "assume_billing_management" {
  group      = aws_iam_group.finance.name
  policy_arn = aws_iam_policy.assume_billing_management.arn
}

## Grace assume IAM ADMIN
resource "aws_iam_group_policy_attachment" "assume_iam_admin_operations" {
  group      = aws_iam_group.user_management.name
  policy_arn = aws_iam_policy.assume_iam_admin_operations.arn
}

## Full admin
resource "aws_iam_group_policy_attachment" "assume_full_admin_management" {
  group      = aws_iam_group.full_admin.name
  policy_arn = aws_iam_policy.assume_full_admin_management.arn
}

## 

resource "aws_iam_group_policy_attachment" "incident_response_secops" {
  group      = aws_iam_group.incident_response.name
  policy_arn = aws_iam_policy.incident_response_secops.arn
}

# Roles - Policy Attachements 

##  billing policy attach

resource "aws_iam_role_policy_attachment" "billing_management" {
  role       = aws_iam_role.billing_management.name
  policy_arn = aws_iam_policy.billing_management.arn
}

##  admin attach
resource "aws_iam_role_policy_attachment" "iam_admin_operations" {
  role       = aws_iam_role.iam_admin_operations.name
  policy_arn = aws_iam_policy.iam_admin_operations.arn
}

## grace mgmt full admin attach
resource "aws_iam_role_policy_attachment" "full_admin_management" {
  role       = aws_iam_role.full_admin_management.name
  policy_arn = aws_iam_policy.full_admin_management.arn
}

## IAM Policy for AWS Config
resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

##
resource "aws_iam_role_policy_attachment" "organization" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}



