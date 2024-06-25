output "kms_arn" {
    value = aws_kms_key.parameter.arn

    description = "arn da chave do kms do parametro"
}

output "kms_key_id" {
    value = aws_kms_key.parameter.key_id

    description = "o id da chave do kms do parametro"
}

output "parameter_arn" {
    value = aws_ssm_parameter.parameter.arn

    description = "arn do parametro"
}

output "parameter_value" {
    value = aws_ssm_parameter.parameter.value

    description = "conteudo do parametro"
}