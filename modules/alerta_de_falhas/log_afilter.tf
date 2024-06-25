
resource "aws_cloudwatch_log_subscription_filter" "alerta_de_erro" {
    count = var.log_group_names != null ? length(var.log_group_names) : 0

    name            = aws_lambda_function.alerta_de_erro.function_name
    log_group_name  = var.log_group_names[count.index]
    filter_pattern  = var.filter_pattern
    destination_arn = aws_lambda_function.alerta_de_erro.arn
    distribution    = "ByLogStream"
}

resource "aws_lambda_permission" "alerta_de_erro" {
    count = var.log_group_names != null ? length(var.log_group_names) : 0

    statement_id = "alerta-de-erro-${var.name}-${count.index}"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.alerta_de_erro.function_name
    principal = "logs.${data.aws_region.region.name}.amazonaws.com"
    source_arn = "arn:aws:logs:${data.aws_region.region.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.log_group_names[count.index]}:*"
}