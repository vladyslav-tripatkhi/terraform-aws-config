locals {
    this_recorder_id = concat(
        aws_config_configuration_recorder.this.*.id,
        aws_config_configuration_recorder.this_with_resource_types.*.id,
        [""]
    )[0]

    s3_bucket_arn = format("arn:aws:s3:::%s", var.s3_bucket_name)

    s3_statements = [{
        sid = "AllowListObjectAction",
        actions = ["s3:ListBucket"],
        resources = [local.s3_bucket_arn]
    }, {
        sid = "AllowGetBucketArnAction",
        actions = ["s3:GetBucketAcl"],
        resources = [local.s3_bucket_arn]
    }]

    dynamic_statements = var.sns_topic_arn == null ? local.s3_statements : concat(local.s3_statements, [{
        sid = "AllowSnsPublishAction",
        actions = ["sns:Publish"],
        resources = [var.sns_topic_arn]
    }])
}

data "aws_iam_policy_document" "assume_role_policy" {
    version = var.policy_version

    statement {
        sid = "AllowAWSConfigToUseThisRole"
        effect = "Allow"
        actions = [
            "sts:AssumeRole"
        ]
        principals {
            type = "Service"
            identifiers = ["config.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "recorder_role" {
    name = "${var.name}_recorded_role"
    assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_config_configuration_recorder" "this" {
    count = var.all_supported && length(var.resource_types) == 0 ? 1 : 0

    name = var.name
    role_arn = aws_iam_role.recorder_role.arn

    recording_group {
        all_supported = var.all_supported
        include_global_resource_types = var.include_global_resource_types
    }
}

resource "aws_config_configuration_recorder" "this_with_resource_types" {
    count = length(var.resource_types) > 0 ? 1 : 0

    name = var.name
    role_arn = aws_iam_role.recorder_role.arn

    recording_group {
        all_supported = false
        resource_types = var.resource_types
    }
}

resource "aws_s3_bucket" "config" {
    count = var.s3_force_new_bucket ? 1 : 0
    bucket = var.s3_bucket_name
    force_destroy = true
}

data "aws_s3_bucket" "config" {
  bucket = var.s3_bucket_name

  depends_on = [aws_s3_bucket.config]
}

data "aws_iam_policy_document" "this" {
    version = var.policy_version

    dynamic "statement" {
        for_each = local.dynamic_statements
        content {
            sid = statement.value.sid
            actions = statement.value.actions
            resources = statement.value.resources
        }
    }

    statement {
        sid = "AllowPutObjectAction"
        actions = ["s3:PutObject"]
        resources = [
            replace("${local.s3_bucket_arn}/${var.s3_key_prefix}/*", "////", "/")
        ]
        condition {
            test = "StringLike"
            variable = "s3:x-amz-acl"
            values = ["bucket-owner-full-control"]
        }
    }
}

resource "aws_iam_role_policy" "access_to_config_bucket" {
    name = "${var.name}_access_${var.s3_bucket_name}"
    role = aws_iam_role.recorder_role.id
    policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "aws_config_role" {
    role = aws_iam_role.recorder_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_config_delivery_channel" "this" {
    name = "${var.name}_delivery_channel"
    s3_bucket_name = var.s3_bucket_name
    s3_key_prefix = var.s3_key_prefix

    sns_topic_arn = var.sns_topic_arn

    snapshot_delivery_properties {
        delivery_frequency = "Six_Hours"
    }

    depends_on = [local.this_recorder_id, aws_iam_role_policy.access_to_config_bucket]
}

resource "aws_config_configuration_recorder_status" "this" {
    name = var.name
    is_enabled = true
    depends_on = [aws_config_delivery_channel.this]
}