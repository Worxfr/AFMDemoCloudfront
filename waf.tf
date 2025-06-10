# WAF Rule Groups for different teams

# Team A WAF Rule Group - OWASP Top 10 Protection (for CloudFront - must be in us-east-1)
resource "aws_wafv2_rule_group" "team_a_rule_group" {
  provider = aws.fms
  name     = "TeamA-OWASP-Protection-${random_id.global_suffix.hex}"
  scope    = "CLOUDFRONT"
  capacity = 700

  rule {
    name     = "SQLiRule"
    priority = 1

    action {
      block {}
    }

    statement {
      sqli_match_statement {
        field_to_match {
          body {
            oversize_handling = "CONTINUE"
          }
        }
        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TeamASQLiRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "XSSRule"
    priority = 2

    action {
      block {}
    }

    statement {
      xss_match_statement {
        field_to_match {
          body {
            oversize_handling = "CONTINUE"
          }
        }
        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TeamAXSSRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "TeamARuleGroupMetric"
    sampled_requests_enabled   = true
  }

  tags = merge(var.team_a_tags, {
    Name = "Team A OWASP Protection Rule Group"
  })
}

# Team B WAF Rule Group - API Protection (for CloudFront - must be in us-east-1)
resource "aws_wafv2_rule_group" "team_b_rule_group" {
  provider = aws.fms
  name     = "TeamB-API-Protection-${random_id.global_suffix.hex}"
  scope    = "CLOUDFRONT"
  capacity = 500

  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TeamBRateLimitMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "BadBotRule"
    priority = 2

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "user-agent"
          }
        }
        positional_constraint = "CONTAINS"
        search_string         = "BadBot"
        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TeamBBadBotMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "TeamBRuleGroupMetric"
    sampled_requests_enabled   = true
  }

  tags = merge(var.team_b_tags, {
    Name = "Team B API Protection Rule Group"
  })
}

# Team A Web ACL Template (for CloudFront - must be in us-east-1)
resource "aws_wafv2_web_acl" "team_a_web_acl" {
  provider = aws.fms
  name     = "TeamA-WebACL-Template-${random_id.global_suffix.hex}"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "TeamARuleGroup"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.team_a_rule_group.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TeamAWebACLMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "TeamAWebACL"
    sampled_requests_enabled   = true
  }

  tags = merge(var.team_a_tags, {
    Name = "Team A Web ACL Template"
  })
}

# Team B Web ACL Template (for CloudFront - must be in us-east-1)
resource "aws_wafv2_web_acl" "team_b_web_acl" {
  provider = aws.fms
  name     = "TeamB-WebACL-Template-${random_id.global_suffix.hex}"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "TeamBRuleGroup"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.team_b_rule_group.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TeamBWebACLMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "TeamBWebACL"
    sampled_requests_enabled   = true
  }

  tags = merge(var.team_b_tags, {
    Name = "Team B Web ACL Template"
  })
}