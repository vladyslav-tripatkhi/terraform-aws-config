resource aws_config_config_rule iam_password_policy_rule {
  count = var.check_iam_password_policy ? 1 : 0

  name        = "iam_password_policy"
  description = "Checks that IAM password policy satisfies the supplied requirements"
  input_parameters = jsonencode({
    MaxPasswordAge             = tostring(var.password_max_age)
    MinimumPasswordLength      = tostring(var.password_minimum_length)
    PasswordReusePrevention    = tostring(var.password_reuse_prevention)
    RequireSymbols             = tostring(var.password_require_symbols)
    RequireNumbers             = tostring(var.password_require_numbers)
    RequireUppercaseCharacters = tostring(var.password_require_uppercase)
    RequireLowercaseCharacters = tostring(var.password_require_lowercase)
  })

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  depends_on = [aws_config_delivery_channel.this]
}

resource aws_config_config_rule iam_user_mfa_enabled_rule {
  count = var.check_iam_user_mfa_enabled ? 1 : 0

  name        = "iam_user_mfa_enabled"
  description = "Checks whether MFA is enabled for every IAM user in your AWS account"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_MFA_ENABLED"
  }

  depends_on = [aws_config_delivery_channel.this]
}

resource aws_config_config_rule iam_user_unused_credentials_check {
  count = var.check_iam_user_unused_credentials ? 1 : 0

  name        = "iam-user-unused-credentials-check"
  description = "Checks whether your AWS IAM users have credentials that have not been used within the specified number of days you provided"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }

  input_parameters = jsonencode({
    maxCredentialUsageAge = tostring(var.max_credential_usage_age)
  })
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "access-keys-rotated" {
  count = var.check_access_keys_rotated ? 1 : 0

  name        = "access-keys-rotated"
  description = "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge"

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  input_parameters = jsonencode({
    maxAccessKeyAge = tostring(var.max_access_key_age)
  })
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "mfa-enabled-for-iam-console-access" {
  count = var.check_mfa_enabled_for_iam_console_access ? 1 : 0

  name        = "mfa-enabled-for-iam-console-access"
  description = "Checks whether MFA is enabled for all IAM users that use a console password"

  source {
    owner             = "AWS"
    source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
  }

  depends_on = [aws_config_delivery_channel.this]
}