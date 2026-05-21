# AWS-EC2-Backup-Terraform

Terraform configuration that uses **AWS Backup** to take daily snapshots of EC2 instances and retain them for **30 days**.

## How it works

| Resource | Purpose |
|---|---|
| `aws_backup_vault` | Stores all recovery points (snapshots) |
| `aws_backup_plan` | Defines the daily schedule and 30-day retention lifecycle |
| `aws_backup_selection` | Selects EC2 instances by tag (`Backup = "true"` by default) |
| `aws_iam_role` | Grants AWS Backup permission to create/restore snapshots |

A backup job runs every day at **05:00 UTC**. Each recovery point is automatically deleted after **30 days**.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS credentials configured (environment variables, `~/.aws/credentials`, or an IAM instance profile)

## Quick start

```bash
# 1. Initialise the working directory
terraform init

# 2. Preview the changes
terraform plan

# 3. Apply
terraform apply
```

Tag any EC2 instance you want backed up:

```bash
aws ec2 create-tags \
  --resources i-0123456789abcdef0 \
  --tags Key=Backup,Value=true
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `aws_region` | AWS region | `us-east-1` |
| `backup_vault_name` | Name for the Backup vault | `ec2-backup-vault` |
| `backup_plan_name` | Name for the Backup plan | `ec2-daily-backup-plan` |
| `backup_retention_days` | Days to keep each recovery point | `30` |
| `backup_schedule` | Cron expression for the backup schedule | `cron(0 5 ? * * *)` |
| `backup_tag_key` | Tag key used to select instances | `Backup` |
| `backup_tag_value` | Tag value used to select instances | `true` |
| `tags` | Extra tags applied to all resources | `{}` |

## Outputs

| Name | Description |
|---|---|
| `backup_vault_arn` | ARN of the backup vault |
| `backup_vault_name` | Name of the backup vault |
| `backup_plan_arn` | ARN of the backup plan |
| `backup_plan_id` | ID of the backup plan |
| `backup_iam_role_arn` | ARN of the IAM role used by AWS Backup |

## Customising retention

To change the retention period, pass the variable at apply time:

```bash
terraform apply -var="backup_retention_days=60"
```

Or add it to a `terraform.tfvars` file:

```hcl
backup_retention_days = 60
```
