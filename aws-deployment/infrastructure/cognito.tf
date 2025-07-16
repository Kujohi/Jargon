###############################################################################
# Amazon Cognito                                                               #
###############################################################################

resource "aws_cognito_user_pool" "main" {
  name = "jargon-ai-userpool-${var.environment}"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  tags = {
    Name = "jargon-userpool-${var.environment}"
  }
}

resource "aws_cognito_user_pool_client" "app_client" {
  name         = "jargon-app-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  callback_urls = [
    "http://localhost:3000/auth/callback",
    "https://${var.domain_name}/auth/callback",
  ]

  logout_urls = [
    "http://localhost:3000",
    "https://${var.domain_name}",
  ]
}