output "invoke_arn" {
    value = aws_lambda_function.rds_resync.*.invoke_arn
}

output "arn" {
    value = aws_lambda_function.rds_resync.*.arn
}

output "function_name" {
    value =  aws_lambda_function.rds_resync.*.function_name
}

output "trusted_role_arn" {
    value =  aws_iam_role.trusted_account_rds_sync.*.arn
}

output "trusted_role_name" {
    value =  aws_iam_role.trusted_account_rds_sync.*.name
}

output "trusting_role_arn" {
    value =  aws_iam_role.trusting_account_rds_sync.*.arn
}

output "trusting_role_name" {
    value =  aws_iam_role.trusting_account_rds_sync.*.name
}