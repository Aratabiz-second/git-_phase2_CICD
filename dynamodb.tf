# ============================================================
# Terraform state lock table
# CI/CDアカウント側のDynamoDBでTerraform backend lockを管理する。
# ============================================================
resource "aws_dynamodb_table" "main" {
  for_each = {
    for key, value in local.dynamodb.keys : key => value if value.required == true
  }

  name         = each.value.name
  billing_mode = local.dynamodb.settings[each.value.setting].billing_mode
  hash_key     = local.dynamodb.settings[each.value.setting].hash_key

  dynamic "attribute" {
    for_each = each.value.attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  point_in_time_recovery {
    enabled = local.dynamodb.settings[each.value.setting].point_in_time_recovery
  }

  server_side_encryption {
    enabled     = local.dynamodb.settings[each.value.setting].sse_enabled
    kms_key_arn = aws_kms_key.main[local.dynamodb.settings[each.value.setting].kms_key_key].arn
  }

  tags = local.dynamodb.settings[each.value.setting].tags
}
