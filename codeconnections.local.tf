# ============================================================
# CodeConnections local settings
# GitHub連携用Connectionの設定値を分離する。
# ============================================================
locals {
  codeconnections = {
    connections = {
      github = {
        name          = local.names.codeconnection_github
        provider_type = "GitHub"
        required      = true
        tags          = local.tags
      }
    }
  }
}
