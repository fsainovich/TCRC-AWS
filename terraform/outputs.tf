#Lambda URL output
output "lambda_url" {
    value = module.public_site.lambda_url    
}

#Cloud distribution URL
output "cloudfront_id" {
    value = module.public_site.cloudfront_id
}