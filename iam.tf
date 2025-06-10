# IAM Roles and Policies for Team-based Access Control

# Service role for AWS Firewall Manager
resource "aws_iam_role" "fms_service_role" {
  provider = aws.security
  name     = "AWSFirewallManagerServiceRole-${random_id.global_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "fms.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "FMS Service Role"
  }
}

# Create a custom policy for FMS service role instead of using the AWS managed policy
resource "aws_iam_policy" "fms_service_policy" {
  provider    = aws.security
  name        = "FMSServicePolicy-${random_id.global_suffix.hex}"
  description = "Custom policy for Firewall Manager service role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "wafv2:*",
          "waf:*",
          "waf-regional:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "ec2:*",
          "shield:*",
          "organizations:DescribeOrganization",
          "organizations:ListAccounts",
          "organizations:ListRoots",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:ListAWSServiceAccessForOrganization",
          "organizations:ListDelegatedAdministrators",
          "config:DescribeConfigurationRecorders",
          "config:DescribeConfigurationRecorderStatus",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:GetBucketAcl",
          "s3:PutBucketAcl",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "FMS Service Policy"
  }
}

# Attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "fms_service_role_policy" {
  provider   = aws.security
  role       = aws_iam_role.fms_service_role.name
  policy_arn = aws_iam_policy.fms_service_policy.arn
}

# IAM Role for Team A Security Engineers
resource "aws_iam_role" "team_a_security_role" {
  provider = aws.security
  name     = "TeamASecurityRole-${random_id.global_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.security_account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "team-a-external-id"
          }
        }
      }
    ]
  })

  tags = var.team_a_tags
}

# IAM Policy for Team A - Limited to their resources
resource "aws_iam_policy" "team_a_fms_policy" {
  provider = aws.security
  name     = "TeamAFirewallManagerPolicy-${random_id.global_suffix.hex}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "fms:GetPolicy",
          "fms:ListPolicies",
          "fms:PutPolicy",
          "fms:DeletePolicy",
          "fms:GetComplianceDetail",
          "fms:ListComplianceStatus"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = var.aws_region
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "wafv2:CreateWebACL",
          "wafv2:UpdateWebACL",
          "wafv2:DeleteWebACL",
          "wafv2:GetWebACL",
          "wafv2:ListWebACLs",
          "wafv2:CreateRuleGroup",
          "wafv2:UpdateRuleGroup",
          "wafv2:DeleteRuleGroup",
          "wafv2:GetRuleGroup",
          "wafv2:ListRuleGroups"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/team" = "team-a"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "organizations:DescribeOrganization",
          "organizations:ListAccounts",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:ListRoots"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.team_a_tags
}

# Attach policy to Team A role
resource "aws_iam_role_policy_attachment" "team_a_policy_attachment" {
  provider   = aws.security
  role       = aws_iam_role.team_a_security_role.name
  policy_arn = aws_iam_policy.team_a_fms_policy.arn
}

# IAM Role for Team B Security Engineers
resource "aws_iam_role" "team_b_security_role" {
  provider = aws.security
  name     = "TeamBSecurityRole-${random_id.global_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.security_account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "team-b-external-id"
          }
        }
      }
    ]
  })

  tags = var.team_b_tags
}

# IAM Policy for Team B - Limited to their resources
resource "aws_iam_policy" "team_b_fms_policy" {
  provider = aws.security
  name     = "TeamBFirewallManagerPolicy-${random_id.global_suffix.hex}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "fms:GetPolicy",
          "fms:ListPolicies",
          "fms:PutPolicy",
          "fms:DeletePolicy",
          "fms:GetComplianceDetail",
          "fms:ListComplianceStatus"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = var.aws_region
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "wafv2:CreateWebACL",
          "wafv2:UpdateWebACL",
          "wafv2:DeleteWebACL",
          "wafv2:GetWebACL",
          "wafv2:ListWebACLs",
          "wafv2:CreateRuleGroup",
          "wafv2:UpdateRuleGroup",
          "wafv2:DeleteRuleGroup",
          "wafv2:GetRuleGroup",
          "wafv2:ListRuleGroups"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/team" = "team-b"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "organizations:DescribeOrganization",
          "organizations:ListAccounts",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:ListRoots"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.team_b_tags
}

# Attach policy to Team B role
resource "aws_iam_role_policy_attachment" "team_b_policy_attachment" {
  provider   = aws.security
  role       = aws_iam_role.team_b_security_role.name
  policy_arn = aws_iam_policy.team_b_fms_policy.arn
}