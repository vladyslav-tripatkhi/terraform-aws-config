output "id" {
  value = concat(
    aws_config_configuration_recorder.this.*.id,
    aws_config_configuration_recorder.this_with_resource_types.*.id,
    [""]
  )[0]
  description = ""
}

output "delivery_channel_id" {
  value       = aws_config_delivery_channel.this.id
  description = ""
}

output "s3_bucket_name" {
  value       = local.s3_bucket_arn
  description = ""
}