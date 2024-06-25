
resource "aws_backup_plan" "ec2_plan" {
    name = "ec2_plan"

    rule {
        rule_name         = "SemanalSnapshot"
        target_vault_name = aws_backup_vault.backup_vault.name
        schedule          = "cron(0 5 ? * 7 *)"

        lifecycle {        
            delete_after = 30
        }
    }

}

# resource "aws_backup_selection" "ec2" {
#   iam_role_arn = aws_iam_role.aws_backup.arn
#   name         = "ec2_backup"
#   plan_id      = aws_backup_plan.ec2_plan.id

#     selection_tag {
#     type  = "STRINGEQUALS"
#     key   = "Backup"
#     value = "true"
#   }

#   resources = [
#     "arn:aws:ec2:*:*:instance/*"
#   ]

# }