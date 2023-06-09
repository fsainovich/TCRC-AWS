#Lambda URL output
output "lambda_url" {
    value = aws_lambda_function_url.views.function_url
}

#Cloud distribution URL
output "cloudfront_id" {
    value = aws_cloudfront_distribution.www_s3_distribution.id
}