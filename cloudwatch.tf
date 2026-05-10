# ============================================================
# CodeBuild log groups
# Validate/Plan と Apply のログを分離し、KMSで暗号化する。
# ============================================================
resource "aws_cloudwatch_log_group" "this" {
  for_each = {
    for key, value in local.cloudwatch.log_groups : key => value if value.required == true
  }

  name              = each.value.name
  retention_in_days = local.cloudwatch.settings[each.value.setting].retention_in_days
  kms_key_id        = aws_kms_key.main[local.cloudwatch.settings[each.value.setting].kms_key_key].arn
  tags              = local.cloudwatch.settings[each.value.setting].tags
}
