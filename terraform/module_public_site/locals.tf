locals {
  resource_name = replace(var.domain_name,".","-")
  s3_origin_id = "S3Origin-${local.resource_name}"
}

