# ============================================================
# KMS local settings
# KMSキーの共通設定と用途別キー定義を分離する。
# ============================================================
locals {
  dir = {
    kmskey_policy = "${path.module}/policies"
  }

  kms = {
    settings = {
      artifact = {
        key_usage                = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation      = true
        deletion_window_in_days  = var.kms.deletion_window_in_days
        rotation_period_in_days  = 365
        multi_region             = false
        policy                   = "kms-key-policy.json"
        params = {
          ACCOUNT = local.account_id
          REGION  = local.region
          KEY_USAGE_PRINCIPAL_ARNS = join("\",\"", [
            aws_iam_role.codepipeline.arn,
            aws_iam_role.codebuild["terraform"].arn,
          ])
          VIA_SERVICE_NAMES     = join("\",\"", ["s3.${local.region}.amazonaws.com"])
          LOG_GROUP_NAME_PREFIX = "/aws/codebuild/${local.prefix}-cb-${local.team}"
        }
        tags = local.tags
      }
      tfstate = {
        key_usage                = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation      = true
        deletion_window_in_days  = var.kms.deletion_window_in_days
        rotation_period_in_days  = 365
        multi_region             = false
        policy                   = "kms-key-policy.json"
        params = {
          ACCOUNT = local.account_id
          REGION  = local.region
          KEY_USAGE_PRINCIPAL_ARNS = join("\",\"", [
            aws_iam_role.codebuild["terraform"].arn,
          ])
          VIA_SERVICE_NAMES     = join("\",\"", ["s3.${local.region}.amazonaws.com"])
          LOG_GROUP_NAME_PREFIX = "/aws/codebuild/${local.prefix}-cb-${local.team}"
        }
        tags = local.tags
      }
      tflock = {
        key_usage                = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation      = true
        deletion_window_in_days  = var.kms.deletion_window_in_days
        rotation_period_in_days  = 365
        multi_region             = false
        policy                   = "kms-key-policy.json"
        params = {
          ACCOUNT = local.account_id
          REGION  = local.region
          KEY_USAGE_PRINCIPAL_ARNS = join("\",\"", [
            aws_iam_role.codebuild["terraform"].arn,
          ])
          VIA_SERVICE_NAMES     = join("\",\"", ["dynamodb.${local.region}.amazonaws.com"])
          LOG_GROUP_NAME_PREFIX = "/aws/codebuild/${local.prefix}-cb-${local.team}"
        }
        tags = local.tags
      }
      logs = {
        key_usage                = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation      = true
        deletion_window_in_days  = var.kms.deletion_window_in_days
        rotation_period_in_days  = 365
        multi_region             = false
        policy                   = "kms-key-policy.json"
        params = {
          ACCOUNT = local.account_id
          REGION  = local.region
          KEY_USAGE_PRINCIPAL_ARNS = join("\",\"", [
            aws_iam_role.codebuild["terraform"].arn,
          ])
          VIA_SERVICE_NAMES     = join("\",\"", ["logs.${local.region}.amazonaws.com"])
          LOG_GROUP_NAME_PREFIX = "/aws/codebuild/${local.prefix}-cb-${local.team}"
        }
        tags = local.tags
      }
      pipeline = {
        key_usage                = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation      = true
        deletion_window_in_days  = var.kms.deletion_window_in_days
        rotation_period_in_days  = 365
        multi_region             = false
        policy                   = "kms-key-policy.json"
        params = {
          ACCOUNT = local.account_id
          REGION  = local.region
          KEY_USAGE_PRINCIPAL_ARNS = join("\",\"", [
            aws_iam_role.codepipeline.arn,
          ])
          VIA_SERVICE_NAMES     = join("\",\"", ["s3.${local.region}.amazonaws.com", "codepipeline.${local.region}.amazonaws.com"])
          LOG_GROUP_NAME_PREFIX = "/aws/codebuild/${local.prefix}-cb-${local.team}"
        }
        tags = local.tags
      }
    }
    keys = {
      artifact = {
        name     = local.names.kms_artifact
        setting  = "artifact"
        required = true
      }
      tfstate = {
        name     = local.names.kms_tfstate
        setting  = "tfstate"
        required = true
      }
      tflock = {
        name     = local.names.kms_tflock
        setting  = "tflock"
        required = true
      }
      logs = {
        name     = local.names.kms_logs
        setting  = "logs"
        required = true
      }
      pipeline = {
        name     = local.names.kms_pipeline
        setting  = "pipeline"
        required = true
      }
    }
  }
}
