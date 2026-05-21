############################################
# ✅ CREATE IAM ROLE (NEW TENANT NEEDS THIS)
############################################
resource "aws_iam_role" "backup_role" {
  name = "AWSBackupServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

############################################
# ✅ BACKUP VAULT (UNIQUE NAME)
############################################
resource "aws_backup_vault" "ec2_backup_vault" {
  name = "ec2-backup-vault-usw2"
}

############################################
# ✅ BACKUP PLAN (UNIQUE NAME)
############################################
resource "aws_backup_plan" "ec2_backup_plan" {
  name = "ec2-daily-backup-plan-usw2"

  rule {
    rule_name         = "daily-30-day-retention"
    target_vault_name = aws_backup_vault.ec2_backup_vault.name
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = 30
    }
  }
}

############################################
# ✅ BACKUP SELECTION (TAG-BASED)
############################################
resource "aws_backup_selection" "ec2_backup_selection" {
  name         = "ec2-tagged-backup-selection-usw2"
  plan_id      = aws_backup_plan.ec2_backup_plan.id
  iam_role_arn = aws_iam_role.backup_role.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}
