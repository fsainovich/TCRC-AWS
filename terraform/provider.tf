terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
/*
provider "aws" {
  alias  = "acm_provider"
  region = var.aws_region
}*/