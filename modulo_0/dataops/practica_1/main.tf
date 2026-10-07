locals {
  # Patrón: <proyecto>-<ambiente>-<servicio>-<recurso>
  # Única fuente de verdad del prefijo: los módulos lo reciben como input.
  name_prefix = "${var.project_name}-${var.environment}"
}

module "kinesis" {
  source = "./modules/kinesis"

  name_prefix = local.name_prefix
  shard_count = var.kinesis_shard_count
}

module "flink" {
  source = "./modules/flink"

  name_prefix        = local.name_prefix
  kinesis_stream_arn = module.kinesis.stream_arn
}
