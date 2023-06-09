# Prepare ZIP file of Python Code of backend to upload to lambda
data "archive_file" "create-note-archive" {
 source_file = "../backend/code/app.py"
 output_path = "/tmp/lambda.zip"
 type = "zip"
}

# Create the lambda function only after DynamoDB Table got updated with views set to 0 on initial apply
resource "aws_lambda_function" "lambda_function" {
    environment {
        variables = {
          VIEWS_TABLE = aws_dynamodb_table.views.name
        }
    }
    memory_size = "128"
    timeout = 10
    runtime = "python3.9"
    architectures = ["arm64"]
    handler = "app.lambda_handler"
    function_name = "views-${local.resource_name}"
    role = aws_iam_role.lambda_access_dynamodb.arn
    filename = "/tmp/lambda.zip"    
    depends_on = [ null_resource.create_views_item ]

    tags = var.common_tags
}

# Create Lambda URL to use in Frontend Javascript to show Page Views
resource "aws_lambda_function_url" "views" {
  function_name      = aws_lambda_function.lambda_function.function_name
  authorization_type = "NONE"
}

# Set Lambda URL in JavaScript
resource "null_resource" "set_lambda_url" {

  provisioner "local-exec" {

    command = "sed -i 's,URL=.*,URL=\"${aws_lambda_function_url.views.function_url}\",g' ../frontend/site/scripts/counter.js"
  }
  depends_on = [ aws_lambda_function_url.views ]

}