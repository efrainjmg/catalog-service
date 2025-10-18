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
    }
  }
}

resource "aws_apigatewayv2_api" "catalog_api" {
  name          = "catalog-api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.catalog_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "list_products_integration" {
  api_id                 = aws_apigatewayv2_api.catalog_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.list_products.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "create_product_integration" {
  api_id                 = aws_apigatewayv2_api.catalog_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.create_product.invoke_arn
  payload_format_version = "2.0"
}

#rutas 
resource "aws_apigatewayv2_route" "list_products_route" {
  api_id    = aws_apigatewayv2_api.catalog_api.id
  route_key = "GET /products"
  target    = "integrations/${aws_apigatewayv2_integration.list_products_integration.id}"
}

resource "aws_apigatewayv2_route" "post_products_route" {
  api_id    = aws_apigatewayv2_api.catalog_api.id
  route_key = "POST /products"
  target    = "integrations/${aws_apigatewayv2_integration.create_product_integration.id}"
}

#despliegue
resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.catalog_api.id
  name        = "dev"
  auto_deploy = true
}

output "catalog_api_url" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}