output "pipeline_name" {
  description = "Created CodePipeline name."
  value       = aws_codepipeline.main.name
}

output "pipeline_arn" {
  description = "Created CodePipeline ARN."
  value       = aws_codepipeline.main.arn
}

output "artifact_bucket_name" {
  description = "Artifact S3 bucket name."
  value       = aws_s3_bucket.main["artifact"].bucket
}

output "tfstate_bucket_name" {
  description = "Terraform state S3 bucket name."
  value       = aws_s3_bucket.main["tfstate"].bucket
}

output "terraform_lock_table_name" {
  description = "Terraform lock DynamoDB table name."
  value       = aws_dynamodb_table.main["terraform_lock"].name
}

output "codebuild_project_names" {
  description = "CodeBuild project names."
  value       = { for k, v in aws_codebuild_project.this : k => v.name }
}

output "codeconnections_connection" {
  description = "CodeConnections connection ARN and status. GitHub approval must be completed before pipeline source execution."
  value = {
    arn    = aws_codeconnections_connection.main["github"].arn
    name   = aws_codeconnections_connection.main["github"].name
    status = aws_codeconnections_connection.main["github"].connection_status
  }
}

output "app_terraform_apply_role_arn" {
  description = "Pre-created APP account role assumed during apply."
  value       = var.app_terraform_apply_role_arn
}

output "apply_before_values_to_replace" {
  description = "Values that must be set before real apply."
  value = {
    github_owner   = var.github_owner
    github_repo    = var.github_repo
    tf_working_dir = var.tf_working_dir
  }
}
