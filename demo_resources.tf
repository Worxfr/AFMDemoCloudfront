# Demo Resources - CloudFront Distributions to test the policies

# S3 Bucket for Dev Environment (Team A)
resource "aws_s3_bucket" "dev_content" {
  provider      = aws.account_dev
  bucket        = "team-a-dev-content-${random_id.global_suffix.hex}"
  force_destroy = true

  tags = merge(var.team_a_tags, {
    Environment = "dev"
    Name        = "Team A Dev Content Bucket"
  })
}

resource "aws_s3_bucket_public_access_block" "dev_content" {
  provider = aws.account_dev
  bucket   = aws_s3_bucket.dev_content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Origin Access Control for Dev CloudFront
resource "aws_cloudfront_origin_access_control" "dev_oac" {
  provider                          = aws.account_dev
  name                              = "team-a-dev-oac-${random_id.global_suffix.hex}"
  description                       = "OAC for Team A Dev Environment"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution for Dev Environment (Team A)
resource "aws_cloudfront_distribution" "dev_distribution" {
  provider = aws.account_dev

  origin {
    domain_name              = aws_s3_bucket.dev_content.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.dev_oac.id
    origin_id                = "S3-${aws_s3_bucket.dev_content.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "Team A Dev Environment Distribution"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.dev_content.bucket}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.team_a_tags, {
    Environment = "dev"
    Name        = "Team A Dev Distribution"
  })
}

# S3 Bucket for Prod Environment (Team B)
resource "aws_s3_bucket" "prod_content" {
  provider      = aws.account_prod
  bucket        = "team-b-prod-content-${random_id.global_suffix.hex}"
  force_destroy = true

  tags = merge(var.team_b_tags, {
    Environment = "prod"
    Name        = "Team B Prod Content Bucket"
  })
}

resource "aws_s3_bucket_public_access_block" "prod_content" {
  provider = aws.account_prod
  bucket   = aws_s3_bucket.prod_content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Origin Access Control for Prod CloudFront
resource "aws_cloudfront_origin_access_control" "prod_oac" {
  provider                          = aws.account_prod
  name                              = "team-b-prod-oac-${random_id.global_suffix.hex}"
  description                       = "OAC for Team B Prod Environment"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution for Prod Environment (Team B)
resource "aws_cloudfront_distribution" "prod_distribution" {
  provider = aws.account_prod

  origin {
    domain_name              = aws_s3_bucket.prod_content.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.prod_oac.id
    origin_id                = "S3-${aws_s3_bucket.prod_content.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "Team B Prod Environment Distribution"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.prod_content.bucket}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.team_b_tags, {
    Environment = "prod"
    Name        = "Team B Prod Distribution"
  })
}
