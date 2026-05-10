# ============================================================
# KMS CMK
# CI/CDアカウント側の用途別Customer managed keyを管理する。
# 設定値は local.kms.settings と local.kms.keys に集約する。
# ============================================================
resource "aws_kms_key" "main" {
  for_each = {
    for key, value in local.kms.keys : key => value if value.required == true
  }

  description              = each.value.name
  key_usage                = local.kms.settings[each.value.setting].key_usage
  customer_master_key_spec = local.kms.settings[each.value.setting].customer_master_key_spec
  enable_key_rotation      = local.kms.settings[each.value.setting].enable_key_rotation
  deletion_window_in_days  = local.kms.settings[each.value.setting].deletion_window_in_days
  rotation_period_in_days  = local.kms.settings[each.value.setting].rotation_period_in_days
  multi_region             = local.kms.settings[each.value.setting].multi_region

  policy = templatefile(
    "${local.dir.kmskey_policy}/${local.kms.settings[each.value.setting].policy}",
    local.kms.settings[each.value.setting].params
  )
  tags = merge(
    local.kms.settings[each.value.setting].tags,
    {
      Name = each.value.name
    },
  )
}

resource "aws_kms_alias" "main" {
  for_each = {
    for key, value in local.kms.keys : key => value if value.required == true
  }

  name          = "alias/${each.value.name}"
  target_key_id = aws_kms_key.main[each.key].key_id
}
