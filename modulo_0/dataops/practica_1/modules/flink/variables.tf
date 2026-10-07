variable "name_prefix" {
  description = "Prefijo estándar <proyecto>-<ambiente> calculado en el módulo raíz."
  type        = string
}

variable "kinesis_stream_arn" {
  description = "ARN del stream Kinesis que consumirá la futura aplicación Flink."
  type        = string
}
