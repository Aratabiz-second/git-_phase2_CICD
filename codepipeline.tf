# ============================================================
# CodePipeline
# GitHub main pushを起点にValidate/PlanとApplyを順番に実行する。
# ============================================================
resource "aws_codepipeline" "main" {
  name     = local.codepipeline.name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.main[local.codepipeline.artifact_store.bucket_key].bucket
    type     = local.codepipeline.artifact_store.type

    encryption_key {
      id   = aws_kms_key.main[local.codepipeline.artifact_store.kms_key_key].arn
      type = "KMS"
    }
  }

  dynamic "stage" {
    for_each = local.codepipeline.stages

    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions

        content {
          name             = action.value.name
          category         = action.value.category
          owner            = action.value.owner
          provider         = action.value.provider
          version          = action.value.version
          run_order        = action.value.run_order
          input_artifacts  = action.value.input_artifacts
          output_artifacts = action.value.output_artifacts
          configuration    = action.value.configuration
        }
      }
    }
  }

  tags = local.codepipeline.tags
}
