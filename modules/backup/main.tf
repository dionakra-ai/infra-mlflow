resource "aws_backup_vault" "backup_vault" {
    name        = "backup_vault"
    kms_key_arn = aws_kms_key.backup_vault.arn

    tags = merge(
        {
            Name = "vault"
        },
        var.tags
    )
}

resource "aws_backup_region_settings" "rds_backup" {
    resource_type_opt_in_preference = {
    "Aurora"          = true
    "DocumentDB"      = true
    "DynamoDB"        = true
    "EBS"             = true
    "EC2"             = true
    "EFS"             = true
    "FSx"             = true
    "Neptune"         = true
    "RDS"             = true
    "Storage Gateway" = true
    "VirtualMachine"  = true
    "S3"              = true
    }
}

resource "aws_iam_role" "aws_backup" {
  name               = "aws_backup"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws_backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.aws_backup.name
}


#resource "aws_backup_vault_lock_configuration" "rds_vault" {
#    backup_vault_name   = aws_backup_vault.rds_vault.name
#    changeable_for_days = var.changeable_for_days
#    max_retention_days  = var.max_retention_days
#    min_retention_days  = var.min_retention_days
#}

# resource "aws_backup_vault_policy" "backup_vault" {
#     backup_vault_name = aws_backup_vault.backup_vault.name

#     policy =  <<POLICY
#     {
#     "Version": "2012-10-17",
#     "Id": "vault_policy",
#     "Statement": [
#         {
#             "Effect": "Deny",
#             "Principal": {
#                 "AWS": "*"
#             },
#             "Action": [
#                 "backup:DeleteBackupVault",
#                 "backup:PutBackupVaultAccessPolicy",
#                 "backup:DeleteBackupVaultAccessPolicy",
# 				"backup:DeleteBackupSelection",
# 				"backup:DeleteBackupPlan",
# 				"backup:StopBackupJob",
#                 "backup:DeleteRecoveryPoint",
#                 "backup:DisassociateRecoveryPoint",
#                 "backup:UpdateRecoveryPointLifecycle"
#             ],
#             "Resource": "${aws_backup_vault.backup_vault.arn}"
#         }
#     ]
# } 
# POLICY
# }