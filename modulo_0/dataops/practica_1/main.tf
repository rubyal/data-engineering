locals {
  # Patrón: <proyecto>-<ambiente>-<servicio>-<recurso>
  name_prefix = "ruby"
}

# Los recursos AWS se agregarán de forma incremental.
# Futuro: módulos para Kinesis Data Streams y Amazon Managed Service
# for Apache Flink, con IAM de mínimo privilegio.
# Ejemplo futuro: name = "${local.name_prefix}-kinesis-events"
