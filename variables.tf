variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "backup_vault_name" {
  description = "Name of the AWS Backup vault"
  type        = string
  default     = "ec2-backup-vault"
}

variable "backup_plan_name" {
  description = "Name of the AWS Backup plan"
  type        = string
  default     = "ec2-daily-backup-plan"
}

variable "backup_retention_days" {
  description = "Number of days to retain EC2 backups"
  type        = number
  default     = 30
}

variable "backup_schedule" {
  description = "Cron expression for the backup schedule (default: daily at 05:00 UTC)"
  type        = string
  default     = "cron(0 5 ? * * *)"
}

variable "backup_tag_key" {
  description = "Tag key used to select EC2 instances for backup"
  type        = string
  default     = "Backup"
}

variable "backup_tag_value" {
  description = "Tag value used to select EC2 instances for backup"
  type        = string
  default     = "true"
}

variable "tags" {
  description = "Additional tags to apply to all created resources"
  type        = map(string)
  default     = {}
}
