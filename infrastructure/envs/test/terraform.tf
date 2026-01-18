terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.28.0" # pinned to a specific version to ensure compatibility and stop any accidental breaking changes!
    }
    awscc = {
      source  = "hashicorp/awscc" # pinned to a specific version to ensure compatibility and stop any accidental breaking changes!
      version = "1.55.0"
    }
  }
}