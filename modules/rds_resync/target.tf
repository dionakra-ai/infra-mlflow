resource "aws_iam_role" "trusting_account_rds_sync" {
    count = var.base_account ? 0 : 1

    name = "rds_sync_${var.target_rds_id}"
    description = "conta que recebe a restauracao de rds"

    assume_role_policy = templatefile("${path.module}/trusting_role.json", {
        TRUSTED_IAM_ROLE = local.trusted_iam_arn
    })

    tags = merge(
        {
            Name        = "rds_sync_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_iam_policy" "trusting_account_rds_sync" {
    count = var.base_account ? 0 : 1

    name        = "rds_sync_${var.target_rds_id}"
    path        = "/"
    description = "politica do restaurador de resync que recebe a restauracao"

    policy = templatefile("${path.module}/trusting_policy.json", {
        ARNS_DO_RDS = jsonencode(flatten([local.target_option_group_arns, local.base_option_group_arns, local.target_parameter_group_arns, local.target_security_group_arns, local.target_subnet_group_arns, ["${local.target_rds_arn}*"], ["${local.snapshot_arn}*"]]))
        ARN_DO_RDS_A_SER_RESTAURADO = local.target_rds_arn
    })

    tags = merge(
        {
            Name        = "rds_sync_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_iam_role_policy_attachment" "trusting_account_rds_sync" {
    count = var.base_account ? 0 : 1

    role       = aws_iam_role.trusting_account_rds_sync[count.index].name
    policy_arn = aws_iam_policy.trusting_account_rds_sync[count.index].arn
}