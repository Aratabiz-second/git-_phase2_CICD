# ============================================================
# CodePipeline local settings
# Pipeline本体、Artifact store、Stage/Action設定を分離する。
# ============================================================
locals {
  codepipeline = {
    name = local.names.codepipeline
    artifact_store = {
      bucket_key  = "artifact"
      kms_key_key = "artifact"
      type        = "S3"
    }
    stages = [
      {
        name = "Source"
        actions = [
          {
            name             = "GitHubSource"
            category         = "Source"
            owner            = "AWS"
            provider         = "CodeStarSourceConnection"
            version          = "1"
            run_order        = 1
            input_artifacts  = []
            output_artifacts = ["SourceOutput"]
            configuration = {
              ConnectionArn        = aws_codeconnections_connection.main["github"].arn
              FullRepositoryId     = "${var.github_owner}/${var.github_repo}"
              BranchName           = var.github_branch
              DetectChanges        = "true"
              OutputArtifactFormat = "CODE_ZIP"
            }
          }
        ]
      },
      {
        name = "Plan"
        actions = [
          {
            name             = "Plan"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            version          = "1"
            run_order        = 1
            input_artifacts  = ["SourceOutput"]
            output_artifacts = ["PlanOutput"]
            configuration = {
              ProjectName = aws_codebuild_project.this["terraform"].name
            }
          }
        ]
      },
      {
        name = "ManualApproval"
        actions = [
          {
            name             = "ApproveTerraformApply"
            category         = "Approval"
            owner            = "AWS"
            provider         = "Manual"
            version          = "1"
            run_order        = 1
            input_artifacts  = []
            output_artifacts = []
            configuration = {
              CustomData = "Review the PlanOutput artifact and approve Terraform apply."
            }
          }
        ]
      },
      {
        name = "Apply"
        actions = [
          {
            name             = "ApplySavedPlan"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            version          = "1"
            run_order        = 1
            input_artifacts  = ["PlanOutput"]
            output_artifacts = []
            configuration = {
              ProjectName       = aws_codebuild_project.this["terraform"].name
              PrimarySource     = "PlanOutput"
              BuildspecOverride = "buildspec.yml"
            }
          }
        ]
      }
    ]
    tags = local.tags
  }
}
