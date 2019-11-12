variable "name" {
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
    type = bool
    default = true
    description = ""
}

variable resource_types {
    type = list(string)
    default = []
    description = ""
}

variable s3_force_new_bucket {
    type = bool
    default = false
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
    type = string
    default = null
    description = ""
}

variable policy_version {
    type = string
    default = "2012-10-17"
    description = ""
}

variable password_policy_create {
	type = bool
	default = true
	description = ""
}
variable password_minimum_length {
	type = number
	default = 12
	description = ""
}
variable password_max_age {
	type = number
	default = 90
	description = ""
}
variable password_reuse_prevention {
	type = number
	default = 3
	description = ""
}
variable password_require_numbers {
	type = bool
	default = true
	description = ""
}
variable password_require_symbols {
	type = bool
	default = true
	description = ""
}
variable password_require_lowercase {
	type = bool
	default = true
	description = ""
}
variable password_require_uppercase {
	type = bool
	default = true
	description = ""
}
variable allow_users_to_change_password {
	type = bool
	default = true
	description = ""
}