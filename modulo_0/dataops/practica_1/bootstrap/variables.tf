variable "region" {
  description = "Región AWS donde se almacenará el estado remoto."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Nombre globalmente único del bucket S3 para el state de Terraform."
  type        = string
}

variable "lock_table_name" {
  description = "Nombre de la tabla DynamoDB utilizada para state locking."
  type        = string
  default     = "terraform-locks"
}
