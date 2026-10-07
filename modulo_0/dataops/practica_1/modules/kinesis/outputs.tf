output "stream_name" {
  description = "Nombre del Kinesis Data Stream."
  value       = aws_kinesis_stream.this.name
}

output "stream_arn" {
  description = "ARN del Kinesis Data Stream."
  value       = aws_kinesis_stream.this.arn
}
