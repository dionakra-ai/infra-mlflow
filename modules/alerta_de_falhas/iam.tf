resource "aws_iam_role" "alerta_de_erro" {
    name = "${var.name}-alerta-de-erro"
    description = "role do alerta de erro"

    assume_role_policy = file("${path.module}/policy/alerta_de_erro_role.json")

    tags = merge({
            Name = "${var.name}-alerta_de_erro"
        },
        var.tags
    )
}

resource "aws_iam_policy" "alerta_de_erro" {
    name        = "${var.name}-alerta-de-erro"
    path        = "/"
    description = "politica com acesso a logs do alerta de erro"

    policy = templatefile("${path.module}/policy/alerta_de_erro_policy.json", {
        LOG_ARN = aws_cloudwatch_log_group.alerta_de_erro.arn
    })
}

resource "aws_iam_role_policy_attachment" "alerta_de_erro" {
    role       = aws_iam_role.alerta_de_erro.name
    policy_arn = aws_iam_policy.alerta_de_erro.arn
}