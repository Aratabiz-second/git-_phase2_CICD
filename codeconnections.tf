# ------------------------------------------------------------
# CodeConnections connections
# ------------------------------------------------------------
resource "aws_codeconnections_connection" "main" {
  for_each = {
    for key, value in local.codeconnections.connections : key => value if value.required == true
  }

  name          = each.value.name
  provider_type = each.value.provider_type

  tags = each.value.tags
}
