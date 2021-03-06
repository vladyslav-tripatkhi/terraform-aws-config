# AWS Config recorder settings

variable name {
  type        = string
  default     = "default"
  description = ""
}

variable all_supported {
  type        = bool
  default     = true
  description = ""
}

variable include_global_resource_types {
  type        = bool
  default     = true
  description = ""
}

variable resource_types {
  type        = list(string)
  default     = []
  description = ""
}

# AWS Config recorder delivery channel settings

variable s3_force_new_bucket {
  type        = bool
  default     = false
  description = ""
}

variable s3_bucket_name {
  type        = string
  default     = null
  description = ""
}

variable s3_key_prefix {
  type        = string
  default     = ""
  description = ""
}

variable sns_topic_arn {
  type        = string
  default     = null
  description = ""
}

# AWS Config IAM rules settings

## ToDo: replace separate bool variables with list with rule names 

variable check_iam_password_policy {
  type        = bool
  default     = true
  description = ""
}

variable check_iam_user_mfa_enabled {
  type        = bool
  default     = true
  description = ""
}

variable check_iam_user_unused_credentials {
  type        = bool
  default     = true
  description = ""
}

variable check_mfa_enabled_for_iam_console_access {
  type        = bool
  default     = true
  description = ""
}

variable check_access_keys_rotated {
  type        = bool
  default     = true
  description = ""
}


variable password_minimum_length {
  type        = number
  default     = 12
  description = ""
}

variable password_max_age {
  type        = number
  default     = 90
  description = ""
}

variable password_reuse_prevention {
  type        = number
  default     = 3
  description = ""
}

variable password_require_numbers {
  type        = bool
  default     = true
  description = ""
}

variable password_require_symbols {
  type        = bool
  default     = true
  description = ""
}

variable password_require_lowercase {
  type        = bool
  default     = true
  description = ""
}

variable password_require_uppercase {
  type        = bool
  default     = true
  description = ""
}


variable max_credential_usage_age {
  type        = number
  default     = 90
  description = ""
}

variable max_access_key_age {
  type        = number
  default     = 90
  description = ""
}