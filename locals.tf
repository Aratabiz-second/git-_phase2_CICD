data "aws_caller_identity" "current" {}

# ============================================================
# Common local settings
# 複数サービスから参照する共通値、タグ、命名規則の入口だけを定義する。
# サービス固有のmapは各 <service>.local.tf に分離する。
# ============================================================
locals {
  prefix         = var.common.prefix
  team           = var.common.team
  env            = var.common.env
  region         = var.common.region
  account_id     = var.accounts.cicd_account_id
  app_account_id = var.accounts.app_account_id

  tags = merge(
    var.default_tag,
    {
      ManagedBy = "Terraform"
    }
  )

  names = {
    artifact_bucket            = "${local.prefix}-s3-${local.team}-artifact-01"
    tfstate_bucket             = "${local.prefix}-s3-${local.team}-tfstate-01"
    tflock_table               = "${local.prefix}-ddb-${local.team}-tflock-01"
    kms_artifact               = "${local.prefix}-kms-${local.team}-artifact-01"
    kms_tfstate                = "${local.prefix}-kms-${local.team}-tfstate-01"
    kms_tflock                 = "${local.prefix}-kms-${local.team}-tflock-01"
    kms_logs                   = "${local.prefix}-kms-${local.team}-codebuild-logs-01"
    kms_pipeline               = "${local.prefix}-kms-${local.team}-codepipeline-01"
    codepipeline               = "${local.prefix}-cp-${local.team}-terraform-01"
    codebuild_terraform        = "${local.prefix}-cb-${local.team}-terraform-01"
    codeconnection_github      = "${local.prefix}-cc-${local.team}-github-01"
    codepipeline_role          = "${local.prefix}-iam-${local.team}-codepipeline-01"
    codebuild_terraform_role   = "${local.prefix}-iam-${local.team}-codebuild-terraform-01"
    codepipeline_policy        = "${local.prefix}-iam-${local.team}-codepipeline-policy-01"
    codebuild_terraform_policy = "${local.prefix}-iam-${local.team}-codebuild-terraform-policy-01"
  }
}
