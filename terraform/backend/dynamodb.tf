resource "aws_dynamodb_table" "globo_clima_users" {
  name         = "GloboClimaUsers"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "Username"

  attribute {
    name = "Username"
    type = "S"
  }
}

resource "aws_dynamodb_table" "globo_clima_favorites" {
  name         = "GloboClimaFavorites"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }
}
