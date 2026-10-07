output "resource_name_prefix" {
  description = "Prefijo estándar que usarán los recursos del proyecto."
  value       = local.name_prefix
}

output "aws_region" {
  description = "Región AWS configurada para la plataforma."
  value       = var.region
}

output "kinesis_stream_name" {
  description = "Nombre del Kinesis Data Stream."
  value       = module.kinesis.stream_name
}

output "kinesis_stream_arn" {
  description = "ARN del Kinesis Data Stream."
  value       = module.kinesis.stream_arn
}

output "flink_application_name" {
  description = "Nombre reservado para la futura aplicación Flink."
  value       = module.flink.application_name
}
