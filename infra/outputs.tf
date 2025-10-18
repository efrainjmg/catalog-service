output "create_product_lambda_arn" {
  value = aws_lambda_function.create_product.arn
}

output "list_products_lambda_arn" {
  value = aws_lambda_function.list_products.arn
}

output "catalog_table_name" {
  value = aws_dynamodb_table.catalog.name
}
