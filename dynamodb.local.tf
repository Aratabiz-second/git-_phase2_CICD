# ============================================================
# DynamoDB local settings
# Terraform state lock table の設定値を分離する。
# ============================================================
locals {
  dynamodb = {
    settings = {
      terraform_lock = {
        billing_mode           = "PAY_PER_REQUEST"
        hash_key               = "LockID"
        point_in_time_recovery = true
        sse_enabled            = true
        kms_key_key            = "tflock"
        tags                   = local.tags
      }
    }
    keys = {
      terraform_lock = {
        name     = local.names.tflock_table
        setting  = "terraform_lock"
        required = true
        attributes = [
          {
            name = "LockID"
            type = "S"
          }
        ]
      }
    }
  }
}
