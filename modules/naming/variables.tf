variable "prefix" {
  description = "Prefix to be used for all resources (e.g., team name, environment)"
  type        = string
  default     = ""
}

variable "name" {
  description = "Base name for the resource"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
  default     = ""
}