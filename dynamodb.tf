resource "aws_dynamodb_table" "main" {
  name           = var.project_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  ttl {
    attribute_name = "Expire"
    enabled        = true
  }

}