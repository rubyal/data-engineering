output "resource_name_prefix" {
  description = "Prefijo estándar que usarán los recursos del proyecto."
  value       = local.name_prefix
}

output "aws_region" {
  description = "Región AWS configurada para la plataforma."
  value       = var.region
}
