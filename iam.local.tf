# ============================================================
# IAM local settings
# CodePipeline / CodeBuild のRole、Policy、Attachment設定を分離する。
# ============================================================
locals {
  iam = {
    roles = {
      codepipeline = {
        name           = local.names.codepipeline_role
        trust_policy   = "codepipeline-trust.json"
        principal_type = "codepipeline"
        tags           = local.tags
      }
      terraform = {
        name           = local.names.codebuild_terraform_role
        trust_policy   = "codebuild-trust.json"
        principal_type = "codebuild"
        tags           = local.tags
      }
    }
    codepipeline_policy = {
      name          = local.names.codepipeline_policy
      template_file = "codepipeline-permissions.json"
      tags          = local.tags
    }
    codebuild_policies = {
      terraform = {
        name          = local.names.codebuild_terraform_policy
        template_file = "codebuild-terraform-permissions.json"
        role_key      = "terraform"
        tags          = local.tags
      }
    }
  }

  iam_policy_params = {
    codepipeline = {
      aws_region                      = local.region
      connection_arn                  = aws_codeconnections_connection.main["github"].arn
      codebuild_terraform_project_arn = aws_codebuild_project.this["terraform"].arn
      artifact_bucket_arn             = aws_s3_bucket.main["artifact"].arn
      artifact_bucket_objects_arn     = "${aws_s3_bucket.main["artifact"].arn}/*"
      artifact_kms_key_arn            = aws_kms_key.main["artifact"].arn
      pipeline_kms_key_arn            = aws_kms_key.main["pipeline"].arn
    }
    codebuild = {
      aws_region                      = local.region
      app_terraform_apply_role_arn    = var.app_terraform_apply_role_arn
      artifact_bucket_arn             = aws_s3_bucket.main["artifact"].arn
      artifact_bucket_objects_arn     = "${aws_s3_bucket.main["artifact"].arn}/*"
      tfstate_bucket_arn              = aws_s3_bucket.main["tfstate"].arn
      tfstate_bucket_objects_arn      = "${aws_s3_bucket.main["tfstate"].arn}/*"
      terraform_lock_table_arn        = aws_dynamodb_table.main["terraform_lock"].arn
      codebuild_log_group_streams_arn = "${aws_cloudwatch_log_group.this["terraform"].arn}:*"
      artifact_kms_key_arn            = aws_kms_key.main["artifact"].arn
      tfstate_kms_key_arn             = aws_kms_key.main["tfstate"].arn
      tflock_kms_key_arn              = aws_kms_key.main["tflock"].arn
      logs_kms_key_arn                = aws_kms_key.main["logs"].arn
    }
  }
}
