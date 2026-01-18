terraform {
  required_version = "= 1.10.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.28.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.55.0"
    }
  }
}