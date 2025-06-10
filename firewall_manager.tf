# AWS Firewall Manager Policies

# S3 bucket for WAF logs
resource "aws_s3_bucket" "waf_logs" {
  provider      = aws.fms
  bucket        = "aws-waf-logs-${random_id.global_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "WAF Logs Bucket"
    Description = "Centralized WAF logs for all accounts"
    ManagedBy   = "Terraform"
  }
}

# Block public access to the WAF logs bucket
resource "aws_s3_bucket_public_access_block" "waf_logs" {
  provider = aws.fms
  bucket   = aws_s3_bucket.waf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy for WAF logs
resource "aws_s3_bucket_policy" "waf_logs" {
  provider = aws.fms
  bucket   = aws_s3_bucket.waf_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWAFLogging"
        Effect = "Allow"
        Principal = {
          Service = "waf.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.waf_logs.arn,
          "${aws_s3_bucket.waf_logs.arn}/*"
        ]
      },
      {
        Sid    = "AWSLogDeliveryWriteFMS"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.waf_logs.arn}/*/AWSLogs/*"
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryAclCheckFMS"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.waf_logs.arn
      }
    ]
  })
}

# Team A Firewall Manager Policy - Applied to Dev Account
resource "aws_fms_policy" "team_a_policy" {
  provider                           = aws.fms
  name                               = "TeamA-WAF-Policy-${random_id.global_suffix.hex}"
  resource_type                      = "AWS::CloudFront::Distribution"
  remediation_enabled                = true
  delete_unused_fm_managed_resources = true
  exclude_resource_tags              = false

  # Apply to specific accounts
  include_map {
    account = [var.dev_account_id]
  }

  security_service_policy_data {
    type = "WAFV2"
    managed_service_data = jsonencode({
      type = "WAFV2"
      preProcessRuleGroups = [
        {
          ruleGroupArn   = aws_wafv2_rule_group.team_a_rule_group.arn
          overrideAction = { type = "NONE" }
          ruleGroupType = "RuleGroup"
          excludeRules  = []
        }
      ]
      postProcessRuleGroups = []
      defaultAction = {
        type = "ALLOW"
      }
      overrideCustomerWebACLAssociation = false
      loggingConfiguration = {
        logDestinationConfigs = [
          aws_s3_bucket.waf_logs.arn
        ]
        redactedFields = []
      }
    })
  }

  tags = merge(var.team_a_tags, {
    Name        = "Team A WAF Policy"
    Description = "Centralized WAF policy managed by Team A"
  })

  depends_on = [aws_s3_bucket_policy.waf_logs]
}

# Team B Firewall Manager Policy - Applied to Prod Account
resource "aws_fms_policy" "team_b_policy" {
  provider                           = aws.fms
  name                               = "TeamB-WAF-Policy-${random_id.global_suffix.hex}"
  resource_type                      = "AWS::CloudFront::Distribution"
  remediation_enabled                = true
  delete_unused_fm_managed_resources = true
  exclude_resource_tags              = false

  # Apply to specific accounts
  include_map {
    account = [var.prod_account_id]
  }

  security_service_policy_data {
    type = "WAFV2"
    managed_service_data = jsonencode({
      type = "WAFV2"
      preProcessRuleGroups = [
        {
          ruleGroupArn   = aws_wafv2_rule_group.team_b_rule_group.arn
          overrideAction = { type = "NONE" }
          ruleGroupType = "RuleGroup"
          excludeRules  = []
        }
      ]
      postProcessRuleGroups = []
      defaultAction = {
        type = "ALLOW"
      }
      overrideCustomerWebACLAssociation = false
      loggingConfiguration = {
        logDestinationConfigs = [
          aws_s3_bucket.waf_logs.arn
        ]
        redactedFields = []
      }
    })
  }

  tags = merge(var.team_b_tags, {
    Name        = "Team B WAF Policy"
    Description = "Centralized WAF policy managed by Team B"
  })

  depends_on = [aws_s3_bucket_policy.waf_logs]
}

# Common Security Policy for All Accounts (managed by central security team)
resource "aws_fms_policy" "common_security_policy" {
  provider                           = aws.fms
  name                               = "Common-Security-Policy-${random_id.global_suffix.hex}"
  resource_type                      = "AWS::CloudFront::Distribution"
  remediation_enabled                = true
  delete_unused_fm_managed_resources = true
  exclude_resource_tags              = false

  # Apply to all accounts in the organization
  include_map {
    account = [var.dev_account_id, var.prod_account_id]
  }

  security_service_policy_data {
    type = "WAFV2"
    managed_service_data = jsonencode({
      type = "WAFV2"
      preProcessRuleGroups = [
        {
          overrideAction = { type = "NONE" }
          managedRuleGroupIdentifier = {
            version              = null
            vendorName           = "AWS"
            managedRuleGroupName = "AWSManagedRulesAmazonIpReputationList"
          }
          ruleGroupType = "ManagedRuleGroup"
          excludeRules  = []
        }
      ]
      postProcessRuleGroups = []
      defaultAction = {
        type = "ALLOW"
      }
      overrideCustomerWebACLAssociation = false
      loggingConfiguration = {
        logDestinationConfigs = [
          aws_s3_bucket.waf_logs.arn
        ]
        redactedFields = []
      }
    })
  }

  tags = {
    Name        = "Common Security Policy"
    Description = "Base security policy applied to all accounts"
    ManagedBy   = "CentralSecurityTeam"
  }

  depends_on = [aws_s3_bucket_policy.waf_logs]
}