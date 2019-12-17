provider "aws" {
  region     = var.aws_region
}

# Data lookups



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



# --------------------
# Groups

resource "aws_iam_group" "devsecops" {
  name = "${var.project}-devsecops"
}

resource "aws_iam_group" "default" {
  name = "${var.project}-default"
}

resource "aws_iam_group" "security_assessment" {
  name = "${var.project}-security-assessment"
}

resource "aws_iam_group" "security_operations" {
  name = "${var.project}-security-operations"
}

resource "aws_iam_group" "finance" {
  name = "${var.project}-finance"
}

resource "aws_iam_group" "user_management" {
  name = "${var.project}-user-management"
}

resource "aws_iam_group" "full_admin" {
  name = "${var.project}-full-admin"
}

resource "aws_iam_group" "incident_response" {
  name = "${var.project}-incident-response"
}

# Create network_admin 



# --------------------
# Roles


## grace mgmt org admin role
resource "aws_iam_role" "management_org_admin" {
  name = "${var.project}-management-org-admin"

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
  name = "${var.project}-full-admin-management"

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
  name = "${var.project}-iam-admin-operations"

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
  name = "${var.project}-config"

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

## Consider moving to cloudwatch?
## Not 100% sure the idea of having dependencies in this role is a good one.
## Role for cloudwatch delivery.
resource "aws_iam_role" "cloudwatch_delivery" {
  name = "${var.project}-cloudwatch_delivery"
  assume_role_policy = <<END_OF_POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
END_OF_POLICY
}


# --------------------
# Policies


data "aws_iam_policy" "read_only_access" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

## policy for MFA
resource "aws_iam_policy" "force_mfa" {
  name        = "${var.project}-force-mfa"
  path        = "/"
  description = "Forces iam users to set MFA to access services"
  policy      = file("${path.module}/files/force_mfa_${env}.json")
}


## Policy for RemoteSourceIPRestriction
resource "aws_iam_policy" "remote_access" {
  name        = "${var.project}-remote-access"
  path        = "/"
  description = "Restrict remote access to whitelisted source IPs"
  policy      = templatefile("${path.module}/templates/remote_access.tpl",)
}


## assume organization account
resource "aws_iam_policy" "assume_org_account_management" {
  name        = "${var.project}-assume-org-account-management"
  description = "Allow access to assume role for view only access to billing and usage"
  path        = "/"
  policy      = file("${path.module}/files/assume_org_account_management.json",{ project = "${var.ip_whitelist }" )  
}

## assume admin policy
resource "aws_iam_policy" "assume_iam_admin_operations" {
  name        = "${var.project}-assume-iam-admin-ops"
  description = "Switch role to manage IAM "
  path        = "/"
  policy      = templatefile("${path.module}/templates/assume_iam_admin_operations.tpl", { project = "${var.project}" } )  
}

## assume fulladmin policy
resource "aws_iam_policy" "assume_full_admin_management" {
  name        = "${var.project}-assume-full-admin-management"
  description = "Break glass - switch role to gain full admin rights and Organizations access"
  path        = "/"
  policy      = templatefile("${path.module}/templates/assume_full_admin_management.tpl", { project = "${var.project}" } ) 
}

## Grace secops IR policy
resource "aws_iam_policy" "incident_response_secops" {
  name        = "${var.project}-incident-response-secops"
  description = "SecOps incident response policy"
  path        = "/"
  policy      = file("${path.module}/files/incident_response_secops.json")  
}

## grace ops admin policy
resource "aws_iam_policy" "iam_admin_operations" {
  name        = "${var.project}-iam-admin-operations"
  description = "Policy to allow full access to manage IAM resources"
  path        = "/"
  policy      = file("${path.module}/files/iam_admin_operations.json")
}


## grace mgmt full admin policy
resource "aws_iam_policy" "full_admin_management" {
  name        = "${var.project}-full-admin-management"
  description = "Policy to allow full admin access"
  path        = "/"
  policy      = file("${path.module}/files/full_admin_management.json")
}



# --------------------
# Policy Attachements


# Groups - Policy Attachements 


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

# Defaults taken from Grace prod

resource "aws_iam_group_policy_attachment" "default_mfa" {
  group      = aws_iam_group.default.name
  policy_arn = aws_iam_policy.force_mfa.arn
}

resource "aws_iam_group_policy_attachment" "default_remote_access" {
  group      = aws_iam_group.default.name
  policy_arn = aws_iam_policy.remote_access.arn
}


# Roles - Policy Attachements 


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



#Readonly Access Role - From Grace Prod

resource "aws_iam_policy_attachment" "read_only_access" {
  name       = "ReadOnlyAccess_attachment"
  groups     = [aws_iam_group.security_assessment.name, aws_iam_group.security_operations.name, aws_iam_group.devsecops.name, aws_iam_group.incident_response.name]
  policy_arn = data.aws_iam_policy.read_only_access.arn
}





