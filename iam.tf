# ============================================================
# IAM roles and policies
# CodePipeline / CodeBuild の実行主体を分離し、ApplyだけがAPP実行アカウントRoleをAssumeRoleできるようにする。
# ============================================================

# ------------------------------------------------------------
# IAM roles
# ------------------------------------------------------------
resource "aws_iam_role" "codepipeline" {
  name = local.iam.roles.codepipeline.name

  assume_role_policy = templatefile("${path.module}/policies/${local.iam.roles.codepipeline.trust_policy}", {})
  tags               = local.iam.roles.codepipeline.tags
}

resource "aws_iam_role" "codebuild" {
  for_each = {
    for key, value in local.iam.roles : key => value if value.principal_type == "codebuild"
  }

  name = each.value.name

  assume_role_policy = templatefile("${path.module}/policies/${each.value.trust_policy}", {})
  tags               = each.value.tags
}

# ------------------------------------------------------------
# IAM policies
# ------------------------------------------------------------
resource "aws_iam_policy" "codepipeline" {
  name = local.iam.codepipeline_policy.name

  policy = templatefile(
    "${path.module}/policies/${local.iam.codepipeline_policy.template_file}",
    local.iam_policy_params.codepipeline
  )
  tags = local.iam.codepipeline_policy.tags
}

resource "aws_iam_policy" "codebuild" {
  for_each = local.iam.codebuild_policies

  name = each.value.name

  policy = templatefile("${path.module}/policies/${each.value.template_file}", local.iam_policy_params.codebuild)
  tags   = each.value.tags
}

# ------------------------------------------------------------
# IAM policy attachments
# ------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  for_each = aws_iam_policy.codebuild

  role       = aws_iam_role.codebuild[local.iam.codebuild_policies[each.key].role_key].name
  policy_arn = each.value.arn
}
