## AWS config recorder Terraform module

This module creates AWS Config and adds several IAM rules with good defaults. As a side bonus it also configures AWS IAM password policy, if asked very politely.
The following config rules are supported (and enabled as of now):
* IAM_PASSWORD_POLICY - ensure that you AWS IAM password policy meets the specified requirements
* IAM_USER_MFA_ENABLED - checks that every IAM user present in that AWS account has configured MFA
* More rules are going to be added in the future as well as the ability to enable or disable them

### Terraform Versions
This module ahs been written with Terraform 0.12 in mind; If this becomes necessarry, 0.11 support will be added in the future.

### Usage
```hcl
module "aws_configuration_recorder" {
    source = "./modules/aws_config_recorder"
    s3_bucket_name = "my-aws-config-bucket"
}
```

### ToDo:
* ~~Add README.md~~
* Add descriptions to variables
* ~~Add configurable delivery_frequency~~
* Move s3 and sns topic creation to a separate module, this one should only accept names/arns
* Add `Inputs` section
* Start working on unit-tests
* Add several more rules and the ability to turn them on and off