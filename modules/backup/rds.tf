

resource "aws_backup_plan" "rds_plan" {
    name = "rds_plan"

    rule {
        rule_name         = "DiarioPITR"
        target_vault_name = aws_backup_vault.backup_vault.name
        enable_continuous_backup = true
        schedule          = "cron(0 5 ? * * *)"
        lifecycle {
            delete_after = 5
        }
    }

      rule {
        rule_name         = "MensalSnapshot"
        target_vault_name = aws_backup_vault.backup_vault.name
        schedule          = "cron(0 1 ? * * *)"

        lifecycle {
            cold_storage_after = 90
            delete_after = 1825 # 5 anos
        }
    }


}

# resource "aws_backup_selection" "rds" {
#   iam_role_arn = aws_iam_role.aws_backup.arn
#   name         = "rds_backup"
#   plan_id      = aws_backup_plan.rds_plan.id

#     selection_tag {
#     type  = "STRINGEQUALS"
#     key   = "Backup"
#     value = "true"
#   }

#   resources = [
#     "arn:aws:rds:*:*:db:*"
#   ]

# }

