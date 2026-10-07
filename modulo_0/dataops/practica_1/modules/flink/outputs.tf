output "application_name" {
  description = "Nombre estándar reservado para la futura aplicación Flink."
  value       = local.application_name
}

output "source_kinesis_stream_arn" {
  description = "ARN del Kinesis stream que será fuente de Flink."
  value       = var.kinesis_stream_arn
}
