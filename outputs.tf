# Output values for the AWS Firewall Manager Demo

output "firewall_manager_admin_account" {
  description = "The AWS account ID configured as Firewall Manager admin"
  value       = var.security_account_id
}

output "team_a_role_arn" {
  description = "ARN of the IAM role for Team A security engineers"
  value       = aws_iam_role.team_a_security_role.arn
}

output "team_b_role_arn" {
  description = "ARN of the IAM role for Team B security engineers"
  value       = aws_iam_role.team_b_security_role.arn
}

output "team_a_waf_rule_group_arn" {
  description = "ARN of Team A's WAF rule group"
  value       = aws_wafv2_rule_group.team_a_rule_group.arn
}

output "team_b_waf_rule_group_arn" {
  description = "ARN of Team B's WAF rule group"
  value       = aws_wafv2_rule_group.team_b_rule_group.arn
}

output "team_a_fms_policy_id" {
  description = "ID of Team A's Firewall Manager policy"
  value       = aws_fms_policy.team_a_policy.id
}

output "team_b_fms_policy_id" {
  description = "ID of Team B's Firewall Manager policy"
  value       = aws_fms_policy.team_b_policy.id
}

output "common_security_policy_id" {
  description = "ID of the common security policy"
  value       = aws_fms_policy.common_security_policy.id
}

output "dev_cloudfront_distribution_id" {
  description = "ID of the dev environment CloudFront distribution"
  value       = aws_cloudfront_distribution.dev_distribution.id
}

output "prod_cloudfront_distribution_id" {
  description = "ID of the prod environment CloudFront distribution"
  value       = aws_cloudfront_distribution.prod_distribution.id
}

output "dev_cloudfront_domain_name" {
  description = "Domain name of the dev environment CloudFront distribution"
  value       = aws_cloudfront_distribution.dev_distribution.domain_name
}

output "prod_cloudfront_domain_name" {
  description = "Domain name of the prod environment CloudFront distribution"
  value       = aws_cloudfront_distribution.prod_distribution.domain_name
}

output "demo_summary" {
  description = "Summary of the demo setup"
  value = {
    description = "AWS Firewall Manager Demo - Centralized WAF Management"
    setup = {
      security_account = var.security_account_id
      dev_account      = var.dev_account_id
      prod_account     = var.prod_account_id
    }
    team_access = {
      team_a = {
        role_arn    = aws_iam_role.team_a_security_role.arn
        manages     = "Dev environment WAF rules (OWASP protection)"
        policy_name = aws_fms_policy.team_a_policy.name
      }
      team_b = {
        role_arn    = aws_iam_role.team_b_security_role.arn
        manages     = "Prod environment WAF rules (API protection)"
        policy_name = aws_fms_policy.team_b_policy.name
      }
    }
    resources_protected = {
      dev_distribution  = aws_cloudfront_distribution.dev_distribution.domain_name
      prod_distribution = aws_cloudfront_distribution.prod_distribution.domain_name
    }
  }
}
