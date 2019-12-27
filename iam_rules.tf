data "template_file" "iam_password_policy" {
    template = file("${path.module}/templates/iam_password_policy.tpl")
    vars = {
        password_minimum_length = var.password_minimum_length
        password_max_age = var.password_max_age
        password_reuse_prevention = var.password_reuse_prevention
        password_require_numbers = var.password_require_numbers
        password_require_symbols = var.password_require_symbols
        password_require_lowercase = var.password_require_lowercase
        password_require_uppercase = var.password_require_uppercase
    }
}

resource "aws_config_config_rule" "iam_password_policy_rule" {
    name = "iam_password_policy"
    description = ""
    input_parameters = data.template_file.iam_password_policy.rendered

    source {
        owner = "AWS"
        source_identifier = "IAM_PASSWORD_POLICY"
    }

    depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "iam_user_mfa_enabled_rule" {
    name = "iam_user_mfa_enabled"
    description = ""
    
    source {
        owner = "AWS"
        source_identifier = "IAM_USER_MFA_ENABLED"
    }

    depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "iam-user-unused-credentials-check" {
    name = "iam-user-unused-credentials-check"
    description = ""

    source {
        owner = "AWS"
        source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
    }

    input_parameters = "{\"maxCredentialUsageAge\":\"90\"}"
    depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "access-keys-rotated" {
    name = "access-keys-rotated"
    description = ""

    source {
        owner = "AWS"
        source_identifier = "ACCESS_KEYS_ROTATED"
    }

    input_parameters = "{\"maxAccessKeyAge\":\"90\"}"
    depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "mfa-enabled-for-iam-console-access" {
  name = "mfa-enabled-for-iam-console-access"
    description = ""

    source {
        owner = "AWS"
        source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
    }
    
    depends_on = [aws_config_delivery_channel.this]
}