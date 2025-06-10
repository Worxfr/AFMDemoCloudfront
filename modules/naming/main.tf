/**
 * This module provides consistent naming for resources across the project
 * It ensures uniqueness by combining a prefix, name, and random suffix
 */

# Generate a random suffix for resource names
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  # Clean the name by replacing invalid characters
  clean_name = replace(var.name, "/[^a-zA-Z0-9-_]/", "")
  
  # Create a standardized name with prefix, name, and suffix
  resource_name = "${var.prefix}-${local.clean_name}-${random_id.suffix.hex}"
  
  # Create a standardized name without hyphens for resources that don't support them
  resource_name_no_hyphens = "${var.prefix}${local.clean_name}${random_id.suffix.hex}"
}

# Output the generated names in different formats
output "name" {
  description = "Standardized resource name with hyphens"
  value       = local.resource_name
}

output "name_no_hyphens" {
  description = "Standardized resource name without hyphens"
  value       = local.resource_name_no_hyphens
}

output "suffix" {
  description = "The random suffix used"
  value       = random_id.suffix.hex
}