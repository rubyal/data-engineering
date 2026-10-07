resource "aws_kinesis_stream" "this" {
  name             = "${var.name_prefix}-kinesis-events"
  shard_count      = var.shard_count
  retention_period = var.retention_hours

  encryption_type = "KMS"
  kms_key_id      = "alias/aws/kinesis"

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  # Se combina con default_tags del provider (Project, Environment, ManagedBy).
  tags = {
    Component = "kinesis"
  }
}
