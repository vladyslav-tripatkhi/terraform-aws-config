output "id" {
    value = local.this_recorder_id
    description = ""
}

output "delivery_channel_id" {
    value = aws_config_delivery_channel.this.id
    description = ""
}

output "s3_bucket_name" {
    value = local.s3_bucket_arn
    description = ""
}