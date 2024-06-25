
resource "aws_backup_plan" "fsx_plan" {
    name = "fsx_plan"

 

    rule {
        rule_name         = "DiarioSnapshot"
        target_vault_name = aws_backup_vault.backup_vault.name
        schedule          = "cron(0 12 * * ? *)"
        
        lifecycle {
            cold_storage_after = 30
            delete_after = 120
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

# resource "aws_backup_selection" "fsx" {
#   iam_role_arn = aws_iam_role.aws_backup.arn
#   name         = "fsx_backup"
#   plan_id      = aws_backup_plan.fsx_plan.id

#     selection_tag {
#     type  = "STRINGEQUALS"
#     key   = "Backup"
#     value = "true"
#   }

#   resources = [
#     "arn:aws:fsx:*:*:file-system/*"
#   ]

# }
