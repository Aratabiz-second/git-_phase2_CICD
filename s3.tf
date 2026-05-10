# ============================================================
# S3 buckets
# Pipeline artifacts と Terraform state をCI/CDアカウント側で分離管理する。
# ============================================================
resource "aws_s3_bucket" "main" {
  for_each = {
    for key, value in local.s3.keys : key => value if value.required == true
  }

  bucket        = each.value.name
  force_destroy = local.s3.settings[each.value.setting].force_destroy
  tags          = local.s3.settings[each.value.setting].tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.main

  bucket                  = each.value.id
  block_public_acls       = local.s3.settings[local.s3.keys[each.key].setting].block_public_access
  block_public_policy     = local.s3.settings[local.s3.keys[each.key].setting].block_public_access
  ignore_public_acls      = local.s3.settings[local.s3.keys[each.key].setting].block_public_access
  restrict_public_buckets = local.s3.settings[local.s3.keys[each.key].setting].block_public_access
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.main

  bucket = each.value.id

  versioning_configuration {
    status = local.s3.settings[local.s3.keys[each.key].setting].versioning_status
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = {
    for key, value in local.s3.keys : key => value if value.required == true && value.lifecycle != null
  }

  bucket = aws_s3_bucket.main[each.key].id

  rule {
    id     = each.value.lifecycle.id
    status = each.value.lifecycle.status

    filter {
      prefix = ""
    }

    expiration {
      days = each.value.lifecycle.expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = each.value.lifecycle.noncurrent_expiration_days
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.main

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.main[local.s3.keys[each.key].kms_key_key].arn
      sse_algorithm     = local.s3.settings[local.s3.keys[each.key].setting].sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "artifact" {
  for_each = {
    for key, value in local.s3.keys : key => value if value.required == true && value.policy != null
  }

  bucket = aws_s3_bucket.main[each.key].id

  policy = templatefile("${path.module}/policies/${each.value.policy}", local.s3_policy_params[each.key])
}

# ------------------------------------------------------------
# S3 objects
# ------------------------------------------------------------
resource "aws_s3_object" "tooling" {
  for_each = {
    for key, value in local.s3.objects : key => value if value.required == true
  }

  bucket                 = aws_s3_bucket.main[each.value.bucket_key].bucket
  key                    = each.value.key
  source                 = each.value.source
  source_hash            = filemd5(each.value.source)
  kms_key_id             = aws_kms_key.main[each.value.kms_key_key].arn
  server_side_encryption = each.value.server_side_encryption
  content_type           = each.value.content_type
  tags                   = each.value.tags
}
