terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.11"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}