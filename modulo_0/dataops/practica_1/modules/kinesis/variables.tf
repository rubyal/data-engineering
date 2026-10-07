variable "name_prefix" {
  description = "Prefijo estándar <proyecto>-<ambiente> calculado en el módulo raíz."
  type        = string
}

variable "shard_count" {
  description = "Cantidad de shards del stream Kinesis en modo PROVISIONED."
  type        = number
  default     = 1

  validation {
    condition     = var.shard_count >= 1
    error_message = "shard_count debe ser al menos 1."
  }
}

variable "retention_hours" {
  description = "Horas de retención de los registros (24 a 8760)."
  type        = number
  default     = 24

  validation {
    condition     = var.retention_hours >= 24 && var.retention_hours <= 8760
    error_message = "retention_hours debe estar entre 24 y 8760."
  }
}
