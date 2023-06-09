variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "codecommit_branch" {
    type = string
}

variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "common_tags" {
  description = "Common tags you want applied to all components."
}