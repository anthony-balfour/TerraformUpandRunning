
# creating output variables to demonstrate state versioning and locking
# arn is amazon resource name - with unique identifier account id: service: resource-id
output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the s3 bucket"
}

#dynamodb table name
output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}