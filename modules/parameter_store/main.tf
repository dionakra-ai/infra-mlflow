resource "aws_kms_key" "parameter" {
    description         = var.description
    enable_key_rotation = true

    policy = var.policy

    tags = merge(
        {
            Name        = var.name
        },
        var.tags
    )
}

resource "aws_ssm_parameter" "parameter" {
    name = var.name
    value = "este valor ainda nao foi setado. favor setar ele"

    type = "SecureString"

    description = var.description

    key_id = aws_kms_key.parameter.arn

    overwrite = false

    lifecycle {
        ignore_changes = [
            value,
        ]
    }

    tags = merge(
        {
            Name        = var.name
        },
        var.tags
    )
}