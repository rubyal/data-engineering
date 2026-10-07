locals {
  application_name = "${var.name_prefix}-flink-stream-processor"
}

# Base del módulo de Amazon Managed Service for Apache Flink.
# La aplicación administrada se añadirá cuando estén definidos:
# - artefacto de código (S3 bucket/key),
# - runtime de Flink,
# - rol IAM de ejecución y permisos mínimos,
# - checkpoints, logging y configuración de aplicación.
#
# El módulo ya recibe el ARN de Kinesis para dejar explícita la
# dependencia Kinesis -> Flink sin inventar todavía credenciales ni código.
