output "invoke_arn" {
    value = aws_lambda_function.lambda_function_executor.invoke_arn
}

output "arn" {
    value = aws_lambda_function.lambda_function_executor.arn
}

output "function_name" {
    value =  aws_lambda_function.lambda_function_executor.function_name
}

output "role_arn" {
    value =  aws_iam_role.lambda_function_executor.arn
}

output "role_name" {
    value =  aws_iam_role.lambda_function_executor.name
}

output "ecr_uri" {
    value = aws_ecr_repository.ecr_repository.*.repository_url
}

output "ecr_arn" {
    value = aws_ecr_repository.ecr_repository.*.arn
}