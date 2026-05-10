variable "common" {
  description = "Common naming and region settings for CI/CD account resources."
  type = object({
    prefix = string
    team   = string
    env    = string
    region = string
  })

  default = {
    prefix = "dev"
    team   = "tk"
    env    = "dev"
    region = "ap-northeast-1"
  }
}

variable "accounts" {
  description = "AWS account IDs used by the CI/CD deployment foundation."
  type = object({
    cicd_account_id = string
    app_account_id  = string
  })
}

variable "default_tag" {
  description = "Common tags applied to resources."
  type        = map(string)

  default = {
    Env     = "dev"
    Project = "tk"
  }
}

variable "app_terraform_apply_role_arn" {
  description = "Pre-created APP account role assumed by the CodeBuild apply project."
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner used by the CodePipeline source action."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name used by the CodePipeline source action."
  type        = string
}

variable "github_branch" {
  description = "GitHub branch that triggers the pipeline."
  type        = string
  default     = "main"
}

variable "terraform_version" {
  description = "Terraform version used in CodeBuild."
  type        = string
  default     = "1.8.5"
}

variable "tf_working_dir" {
  description = "Working directory inside the source artifact where APP Terraform code exists."
  type        = string
  default     = "."
}

variable "tf_state_key" {
  description = "Terraform backend state key for APP runtime resources."
  type        = string
  default     = "app/terraform.tfstate"
}

variable "tf_plan_file" {
  description = "Terraform plan file name passed from validate/plan to apply."
  type        = string
  default     = ".tfplan"
}

variable "log_retention_in_days" {
  description = "CloudWatch Logs retention period for CodeBuild projects."
  type        = number
  default     = 3
}

variable "kms" {
  description = "KMS common settings."
  type = object({
    deletion_window_in_days = number
  })
  default = {
    deletion_window_in_days = 30
  }
}

variable "force_destroy_buckets" {
  description = "Whether S3 buckets can be force destroyed in this rebuild test."
  type        = bool
  default     = false
}
