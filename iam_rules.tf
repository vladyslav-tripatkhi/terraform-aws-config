resource "aws_iam_account_password_policy" "this" {
    count = var.password_policy_create ? 1 : 0
    
    minimum_password_length = var.password_minimum_length
    max_password_age = var.password_max_age
    password_reuse_prevention = var.password_reuse_prevention
    require_numbers = var.password_require_numbers
    require_symbols = var.password_require_symbols
    require_lowercase_characters = var.password_require_lowercase
    require_uppercase_characters = var.password_require_uppercase
    allow_users_to_change_password = var.allow_users_to_change_password
}

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
