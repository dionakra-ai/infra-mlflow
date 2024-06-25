resource "aws_cloudwatch_log_group" "night_sleep" {
    name              = "/aws/lambda/${aws_lambda_function.night_sleep.function_name}"
    retention_in_days = 180

    tags = merge({
            Name = "${local.name}-night_sleep"
        },
        var.tags
    )
}

resource "aws_cloudwatch_event_rule" "night_sleep_fall_asleep" {
    count = var.sleep != null && var.cpu_idle_sleep == null ? 1 : 0

    name                = "night_sleep_fall_asleep_${local.name}"
    description         = "desliga a maquina"

    schedule_expression = var.sleep

    tags = merge({
            Name = "${local.name}-night_sleep_fall_asleep"
        },
        var.tags
    )
}

resource "aws_cloudwatch_event_rule" "night_sleep_wake_up" {
    count = var.wake_up != null && var.cpu_idle_sleep == null ? 1 : 0

    name                = "night_sleep_wake_up_${local.name}"
    description         = "liga a maquina"

    schedule_expression = var.wake_up

    tags = merge({
            Name = "${local.name}-night_sleep_wake_up"
        },
        var.tags
    )
}

resource "aws_cloudwatch_event_target" "night_sleep_fall_asleep" {
    count = var.sleep != null && var.cpu_idle_sleep == null ? 1 : 0

    rule = aws_cloudwatch_event_rule.night_sleep_fall_asleep[count.index].name

    arn = aws_lambda_function.night_sleep.arn

    input = "{\"fall_asleep\":\"true\"}"
}

resource "aws_cloudwatch_event_target" "night_sleep_wake_up" {
    count = var.wake_up != null && var.cpu_idle_sleep == null ? 1 : 0

    rule = aws_cloudwatch_event_rule.night_sleep_wake_up[count.index].name

    arn = aws_lambda_function.night_sleep.arn

    input = "{\"fall_asleep\":\"false\"}"
}

resource "aws_lambda_permission" "night_sleep_fall_asleep" {
    count = var.sleep != null && var.cpu_idle_sleep == null ? 1 : 0

    statement_id = "${local.name}-night_sleep_fall_asleep"
    action = "lambda:InvokeFunction"
    principal = "events.amazonaws.com"
    function_name = aws_lambda_function.night_sleep.function_name
    source_arn = aws_cloudwatch_event_rule.night_sleep_fall_asleep[count.index].arn
}

resource "aws_lambda_permission" "night_sleep_wake_up" {
    count = var.wake_up != null && var.cpu_idle_sleep == null ? 1 : 0

    statement_id = "${local.name}-night_sleep_wake_up"
    action = "lambda:InvokeFunction"
    principal = "events.amazonaws.com"
    function_name = aws_lambda_function.night_sleep.function_name
    source_arn = aws_cloudwatch_event_rule.night_sleep_wake_up[count.index].arn
}