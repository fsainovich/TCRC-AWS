# Create the DynamoDB Table
resource "aws_dynamodb_table" "views" {
  name         = "views-${var.domain_name}"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
  hash_key = "id"
  server_side_encryption { enabled = true }

  tags = var.common_tags

}

# Create and set the views to 0 on DynamoDB Table on ID 1 using aws cli and json document
resource "null_resource" "create_views_item" {

  provisioner "local-exec" {

    command = "aws dynamodb put-item --table-name ${aws_dynamodb_table.views.name} --item file://resources/item.json"

  }
  depends_on = [ aws_dynamodb_table.views ]
}

