# ============================================================
# CodeBuild projects
# PlanとApplyは同じCodeBuild projectをCodePipeline上で2回実行する。
# ============================================================
resource "aws_codebuild_project" "this" {
  for_each = {
    for key, value in local.codebuild.projects : key => value if value.required == true
  }

  name           = each.value.name
  description    = each.value.description
  service_role   = aws_iam_role.codebuild[each.value.role_key].arn
  build_timeout  = local.codebuild.settings[each.value.setting].build_timeout
  encryption_key = aws_kms_key.main[local.codebuild.settings[each.value.setting].encryption_key].arn

  artifacts {
    type = local.codebuild.settings[each.value.setting].artifact_type
  }

  environment {
    compute_type                = local.codebuild.settings[each.value.setting].compute_type
    image                       = local.codebuild.settings[each.value.setting].image
    type                        = local.codebuild.settings[each.value.setting].type
    image_pull_credentials_type = local.codebuild.settings[each.value.setting].credentials

    dynamic "environment_variable" {
      for_each = local.codebuild_environment_variables[each.key]

      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.this[each.value.log_group_key].name
      stream_name = each.key
      status      = "ENABLED"
    }
  }

  source {
    type      = local.codebuild.settings[each.value.setting].source_type
    buildspec = each.value.buildspec
  }

  tags = local.codebuild.settings[each.value.setting].tags
}
