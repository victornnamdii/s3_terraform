# Backend configuration for storing the Terraform state
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Local values to simplify configurations
locals {
  environment = "development"
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

# Provider configuration
provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
