# ============================================================
# CodeBuild local settings
# Plan と Apply は同じCodeBuild projectをCodePipeline上で2回実行する。
# ============================================================
locals {
  codebuild = {
    settings = {
      default = {
        build_timeout  = 30
        encryption_key = "artifact"
        compute_type   = "BUILD_GENERAL1_SMALL"
        image          = "aws/codebuild/standard:7.0"
        type           = "LINUX_CONTAINER"
        credentials    = "CODEBUILD"
        source_type    = "CODEPIPELINE"
        artifact_type  = "CODEPIPELINE"
        tags           = local.tags
      }
    }
    projects = {
      terraform = {
        name          = local.names.codebuild_terraform
        description   = "Plan and apply APP account Terraform using embedded plan buildspec and PlanOutput apply buildspec."
        buildspec     = file("${path.module}/buildspecs/buildspec.yml")
        setting       = "default"
        role_key      = "terraform"
        log_group_key = "terraform"
        required      = true
      }
    }
  }

  codebuild_environment_variables = {
    terraform = {
      TF_VAR_app_terraform_apply_role_arn = var.app_terraform_apply_role_arn
      ARTIFACT_BUCKET_NAME                = local.s3.keys.artifact.name
      TERRAFORM_CLI_ZIP_KEY               = local.s3.objects.terraform_zip.key
      APP_TERRAFORM_ZIP_KEY               = local.s3.objects.app_terraform_zip.key
    }
  }
}
