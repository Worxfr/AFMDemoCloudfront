variable "aws_region" {
  description = "AWS Region for the resources"
  type        = string
  default     = "us-east-1"
}

variable "security_account_id" {
  description = "AWS Account ID for the Security/FMS Admin account"
  type        = string
}

variable "dev_account_id" {
  description = "AWS Account ID for the development environment"
  type        = string
}

variable "prod_account_id" {
  description = "AWS Account ID for the production environment"
  type        = string
}

variable "team_a_tags" {
  description = "Tags for resources managed by Team A"
  type        = map(string)
  default = {
    team = "team-a"
  }
}

variable "team_b_tags" {
  description = "Tags for resources managed by Team B"
  type        = map(string)
  default = {
    team = "team-b"
  }
}
