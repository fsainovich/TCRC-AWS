module "public_site" {
    source = "./module_public_site"

    domain_name = var.domain_name
    codecommit_branch = var.codecommit_branch
    aws_region = var.aws_region
    common_tags = var.common_tags
    
}

