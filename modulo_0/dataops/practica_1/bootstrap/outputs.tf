output "state_bucket_name" {
  description = "Bucket S3 creado para el state remoto."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "lock_table_name" {
  description = "Tabla DynamoDB utilizada para bloquear el state."
  value       = aws_dynamodb_table.terraform_locks.name
}
