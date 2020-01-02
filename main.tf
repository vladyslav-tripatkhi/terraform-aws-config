locals {
  s3_bucket_arn = format("arn:aws:s3:::%s", var.s3_bucket_name)

  s3_statements = [{
    sid       = "AllowListObjectAction",
    actions   = ["s3:ListBucket"],
    resources = [local.s3_bucket_arn]
    }, {
    sid       = "AllowGetBucketArnAction",
    actions   = ["s3:GetBucketAcl"],
    resources = [local.s3_bucket_arn]
  }]

  dynamic_statements = var.sns_topic_arn == null ? local.s3_statements : concat(local.s3_statements, [{
    sid       = "AllowSnsPublishAction",
    actions   = ["sns:Publish"],
    resources = [var.sns_topic_arn]
  }])
}

module "role_aws_config_recorder_role" {
  source = "github.com/vladyslav-tripatkhi/terraform-iam-modules/modules/aws_iam_role"

  name                   = "${var.name}_recorder_role"
  assume_role_principals = [{ type = "Service", identifiers = ["config.amazonaws.com"] }]
  attached_policy_arns   = ["arn:aws:iam::aws:policy/service-role/AWSConfigRole"]

  inline_policy_name = "${var.name}_access_${var.s3_bucket_name}"
  inline_policy_statements = concat(local.dynamic_statements, [{
    sid     = "AllowPutObjectAction"
    actions = ["s3:PutObject"]
    resources = [
      replace("${local.s3_bucket_arn}/${var.s3_key_prefix}/*", "////", "/")
    ]
    conditions = [{
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }]
  }])
}

resource "aws_config_configuration_recorder" "this" {
  count = var.all_supported && length(var.resource_types) == 0 ? 1 : 0

  name     = var.name
  role_arn = module.role_aws_config_recorder_role.arn

  recording_group {
    all_supported                 = var.all_supported
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "aws_config_configuration_recorder" "this_with_resource_types" {
  count = length(var.resource_types) > 0 ? 1 : 0

  name     = var.name
  role_arn = module.role_aws_config_recorder_role.arn

  recording_group {
    all_supported  = false
    resource_types = var.resource_types
  }
}

resource "aws_s3_bucket" "config" {
  count         = var.s3_force_new_bucket ? 1 : 0
  bucket        = var.s3_bucket_name
  force_destroy = true
}

data "aws_s3_bucket" "config" {
  bucket = var.s3_bucket_name

  depends_on = [aws_s3_bucket.config]
}

resource "aws_config_delivery_channel" "this" {
  name           = "${var.name}_delivery_channel"
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix

  sns_topic_arn = var.sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = "Six_Hours"
  }

  depends_on = [
    aws_config_configuration_recorder.this,
    aws_config_configuration_recorder.this_with_resource_types,
    module.role_aws_config_recorder_role
  ]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = var.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}