resource "aws_cloudwatch_log_group" "alerta_de_erro" {
    name              = "/aws/lambda/${aws_lambda_function.alerta_de_erro.function_name}"
    retention_in_days = 180

    tags = merge({
            Name = "${var.name}-alerta_de_erro"
        },
        var.tags
    )
}

data "archive_file" "alerta_de_erro" {
    type             = "zip"
    source_file      = "${path.module}/main.py"
    output_path      = "${path.module}/main.zip"
}

resource "aws_lambda_function" "alerta_de_erro" {
    function_name = "alerta_de_erro_${var.name}"

    filename = data.archive_file.alerta_de_erro.output_path

    source_code_hash = data.archive_file.alerta_de_erro.output_base64sha256

    handler = "main.main"
    runtime = "python3.8"

    role = aws_iam_role.alerta_de_erro.arn

    environment {
        variables = {
            BOT_IMAGE = var.bot_image
            ALERT_HOOK = var.alert_hook
            ENVIRONMENT = terraform.workspace
        }
    }

    tags = merge({
            Name = "${var.name}-alerta_de_erro"
        },
        var.tags
    )
}

resource "aws_lambda_function_event_invoke_config" "alerta_de_erro" {
    function_name = aws_lambda_function.alerta_de_erro.function_name

    maximum_retry_attempts = 0
}