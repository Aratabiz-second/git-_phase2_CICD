# ============================================================
# CloudWatch Logs local settings
# CodeBuildロググループの名前、保持期間、KMS参照を分離する。
# ============================================================
locals {
  cloudwatch = {
    settings = {
      codebuild = {
        retention_in_days = var.log_retention_in_days
        kms_key_key       = "logs"
        tags              = local.tags
      }
    }
    log_groups = {
      terraform = {
        name     = "/aws/codebuild/${local.codebuild.projects.terraform.name}"
        setting  = "codebuild"
        required = true
      }
    }
  }
}
