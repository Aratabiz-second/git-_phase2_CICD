check "cicd_account" {
  assert {
    condition     = data.aws_caller_identity.current.account_id == local.account_id
    error_message = "Terraform must run in the CI/CD account."
  }
}

check "app_role_account" {
  assert {
    condition     = can(regex("^arn:aws:iam::${local.app_account_id}:role/.+", var.app_terraform_apply_role_arn))
    error_message = "app_terraform_apply_role_arn must point to the APP account."
  }
}
