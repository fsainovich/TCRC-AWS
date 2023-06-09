# Create the S3 bucket for website after lambda creation.

resource "aws_s3_bucket" "www_bucket" {

  bucket = "www.${var.domain_name}"
  force_destroy = true
  tags = var.common_tags
  depends_on = [ aws_lambda_function_url.views ]

}

# Create the S3 bucket for pipelines after lambda creation.
resource "aws_s3_bucket" "pipelines" {

  bucket = "pipelines-${var.domain_name}"
  force_destroy = true
  tags = var.common_tags
  depends_on = [ aws_lambda_function_url.views ]

}

/*resource "aws_s3_bucket_public_access_block" "www" {
  bucket = aws_s3_bucket.www_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}*/

# CORS configuration for Site bucket
resource "aws_s3_bucket_cors_configuration" "www" {

  bucket = aws_s3_bucket.www_bucket.id
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain_name}"]
    max_age_seconds = 3000
  }

}

# Configuration for Site bucket
resource "aws_s3_bucket_website_configuration" "wwww-config" {
  bucket = aws_s3_bucket.www_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}