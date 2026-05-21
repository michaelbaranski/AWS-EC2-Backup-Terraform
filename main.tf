# --------------------------------------------------------------------------
# AWS Backup Vault
# Stores the recovery points (snapshots) for all backed-up EC2 instances.
# ---------------------------------------------------------------------------
resource "aws_backup_vault" "ec2_backup_vault" {
  name = var.backup_vault_name
  tags = var.tags
}

# ---------------------------------------------------------------------------
# IAM Role for AWS Backup
# Grants the AWS Backup service permission to create and restore snapshots.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "backup_role" {
  name = "AWSBackupServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# ---------------------------------------------------------------------------
# AWS Backup Plan
# Runs a daily backup job and retains each recovery point for 30 days.
# ---------------------------------------------------------------------------
resource "aws_backup_plan" "ec2_backup_plan" {
  name = var.backup_plan_name

  rule {
    rule_name         = "daily-${var.backup_retention_days}-day-retention"
    target_vault_name = aws_backup_vault.ec2_backup_vault.name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# AWS Backup Selection
# Targets EC2 instances that carry the configurable backup tag (default:
# Backup = "true").  Add that tag to any instance you want included.
# ---------------------------------------------------------------------------
resource "aws_backup_selection" "ec2_backup_selection" {
  name         = "ec2-tagged-backup-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.ec2_backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.backup_tag_key
    value = var.backup_tag_value
  }
}
