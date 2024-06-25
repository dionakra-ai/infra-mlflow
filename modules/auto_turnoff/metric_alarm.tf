resource "aws_cloudwatch_metric_alarm" "night_sleep" {
    count = var.cpu_idle_sleep != null ? length(var.target_id) : 0

    alarm_name        = "${local.name}"
    alarm_description = "sleep - ${local.name} - desliga a maquina ociosa em um dado horario"
    comparison_operator = "LessThanOrEqualToThreshold"
    threshold           = var.cpu_idle_sleep.threshold
    datapoints_to_alarm = var.cpu_idle_sleep.datapoints_to_alarm
    evaluation_periods  = var.cpu_idle_sleep.evaluation_periods
    alarm_actions      = [aws_sns_topic.night_sleep[0].arn]

    metric_query {
        id = "uso_de_cpu_em_um_dado_momento"

        label = "uso da cpu da maquina ${element(var.target_id, count.index)}"

        metric {
            metric_name = "CPUUtilization"
            namespace   = "AWS/EC2"
            stat        = "SampleCount"
            unit        = "Percent"

            period      = var.cpu_idle_sleep.evaluation_periods

            dimensions = {
                InstanceId = element(var.target_id, count.index)
            }
        }
    }

    metric_query {
        id = "comparacao_da_cpu"

        label = "testa a ociosidade da maquina em um dado momento do tempo"

        expression = "IF(HOUR(uso_de_cpu_em_um_dado_momento) > ${element(split(" ", var.sleep), 1)} && HOUR(uso_de_cpu_em_um_dado_momento) < ${var.wake_up != null ? element(split(" ", var.wake_up), 1) : "24"}, uso_de_cpu_em_um_dado_momento, uso_de_cpu_em_um_dado_momento+3)"

        return_data = true
    }

    tags = merge({
            Name = "${local.name}-night_sleep"
        },
        var.tags
    )
}

resource "aws_sns_topic" "night_sleep" {
    count = var.cpu_idle_sleep != null ? 1 : 0

    name = "sleep-${local.name}"

    tags = merge({
            Name = "${local.name}-night_sleep"
        },
        var.tags
    )
}

resource "aws_sns_topic_subscription" "night_sleep" {
    count = var.cpu_idle_sleep != null ? 1 : 0

    topic_arn = aws_sns_topic.night_sleep[count.index].arn
    endpoint  = aws_lambda_function.night_sleep.arn
    protocol  = "lambda"
}

resource "aws_lambda_permission" "night_sleep" {
    count = var.cpu_idle_sleep != null ? 1 : 0

    statement_id = "sleep-${local.name}"
    action = "lambda:InvokeFunction"
    principal = "sns.amazonaws.com"
    function_name = aws_lambda_function.night_sleep.arn
    source_arn = aws_sns_topic.night_sleep[count.index].arn
}