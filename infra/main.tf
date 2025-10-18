provider "aws" {
  region = var.region
}

# DynamoDB Table
resource "aws_dynamodb_table" "catalog" {
  name         = var.catalog_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# IAM Role for Lambdas
resource "aws_iam_role" "lambda_role" {
  name = "catalog_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "catalog_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ],
        Effect = "Allow",
        Resource = aws_dynamodb_table.catalog.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Lambdas
resource "aws_lambda_function" "create_product" {
  function_name = "CreateProductLambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/../lambdas/createProduct/index.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambdas/createProduct/index.zip")

  environment {
    variables = {
      CATALOG_TABLE_NAME = var.catalog_table_name
      AWS_REGION = var.region
    }
  }
}

resource "aws_lambda_function" "list_products" {
  function_name = "ListProductsLambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/../lambdas/listProducts/index.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambdas/listProducts/index.zip")

  environment {
    variables = {
      CATALOG_TABLE_NAME = var.catalog_table_name
      AWS_REGION = var.region
    }
  }
}
