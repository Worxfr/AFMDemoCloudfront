# AWS Firewall Manager Demo - Centralized WAF Management
# This demo shows how to set up centralized WAF rule management with team-based access control

terraform {
  required_version = ">= 1.0"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider for the Security Account (Firewall Manager Admin)
provider "aws" {
  alias  = "security"
  region = var.aws_region
  # This should be the delegated administrator account for Firewall Manager
}

# Configure AWS Provider for Firewall Manager (must be us-east-1 for CloudFront)
provider "aws" {
  alias  = "fms"
  region = "us-east-1"
  # This provider is specifically for Firewall Manager resources
}

# Configure providers for member accounts
provider "aws" {
  alias  = "account_dev"
  region = var.aws_region
  # Configure with dev account credentials
  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "account_prod"
  region = var.aws_region
  # Configure with prod account credentials
  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/OrganizationAccountAccessRole"
  }
}

# Generate a unique identifier for resources
resource "random_id" "global_suffix" {
  byte_length = 4
}
