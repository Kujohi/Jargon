###############################################################################
# Amazon DynamoDB                                                             #
###############################################################################

# Transactions table – partition key = id (uuid), sort key = user_id, with GSI by user/date
resource "aws_dynamodb_table" "transactions" {
  name         = "jargon-transactions-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "id"
  range_key = "user_id"

  attribute { name = "id"      type = "S" }
  attribute { name = "user_id" type = "S" }
  attribute { name = "date"    type = "S" }

  global_secondary_index {
    name            = "user_date_index"
    hash_key        = "user_id"
    range_key       = "date"
    projection_type = "ALL"
  }

  tags = {
    Name = "jargon-transactions-${var.environment}"
  }
}

# Jars table – composite key (user_id, jar_type)
resource "aws_dynamodb_table" "jars" {
  name         = "jargon-jars-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "user_id"
  range_key = "jar_type"

  attribute { name = "user_id"  type = "S" }
  attribute { name = "jar_type" type = "S" }

  tags = {
    Name = "jargon-jars-${var.environment}"
  }
}