# ============================================================
# S3 local settings
# Artifact bucket と Terraform state bucket の設定値を分離する。
# ============================================================
locals {
  s3 = {
    settings = {
      default = {
        force_destroy       = var.force_destroy_buckets
        versioning_status   = "Suspended"
        sse_algorithm       = "aws:kms"
        block_public_access = true
        tags                = local.tags
      }
    }
    keys = {
      artifact = {
        name        = local.names.artifact_bucket
        setting     = "default"
        kms_key_key = "artifact"
        policy      = "artifact-bucket-policy.json"
        lifecycle = {
          id                         = "expire-artifacts-after-30-days"
          status                     = "Enabled"
          expiration_days            = 30
          noncurrent_expiration_days = 1
        }
        required = true
      }
      tfstate = {
        name        = local.names.tfstate_bucket
        setting     = "default"
        kms_key_key = "tfstate"
        policy      = "tfstate-bucket-policy.json"
        lifecycle   = null
        required    = true
      }
    }
    objects = {
      terraform_zip = {
        bucket_key             = "artifact"
        key                    = "tools/terraform/${var.terraform_version}/terraform_${var.terraform_version}_linux_amd64.zip"
        source                 = "${path.module}/tools/terraform/${var.terraform_version}/terraform_${var.terraform_version}_linux_amd64.zip"
        kms_key_key            = "artifact"
        server_side_encryption = "aws:kms"
        content_type           = "application/zip"
        required               = true
        tags                   = local.tags
      }
      app_terraform_zip = {
        bucket_key             = "artifact"
        key                    = "tools/app-terraform/phase2/app_terraform_phase2.zip"
        source                 = "${path.module}/tools/app-terraform/phase2/app_terraform_phase2.zip"
        kms_key_key            = "artifact"
        server_side_encryption = "aws:kms"
        content_type           = "application/zip"
        required               = true
        tags                   = local.tags
      }
    }
  }

  s3_policy_params = {
    artifact = {
      artifact_bucket_allowed_principal_arns = join("\",\"", [
        aws_iam_role.codepipeline.arn,
        aws_iam_role.codebuild["terraform"].arn,
      ])
      artifact_bucket_arn         = aws_s3_bucket.main["artifact"].arn
      artifact_bucket_objects_arn = "${aws_s3_bucket.main["artifact"].arn}/*"
      artifact_kms_key_arn        = aws_kms_key.main["artifact"].arn
    }
    tfstate = {
      tfstate_bucket_allowed_principal_arns = join("\",\"", [
        aws_iam_role.codebuild["terraform"].arn,
      ])
      tfstate_bucket_arn         = aws_s3_bucket.main["tfstate"].arn
      tfstate_bucket_objects_arn = "${aws_s3_bucket.main["tfstate"].arn}/*"
      tfstate_kms_key_arn        = aws_kms_key.main["tfstate"].arn
    }
  }
}
