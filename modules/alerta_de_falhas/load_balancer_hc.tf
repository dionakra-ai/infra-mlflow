resource "aws_cloudwatch_metric_alarm" "alerta_de_erro" {
    count = var.load_balancers != null ? length(var.load_balancers) : 0

    alarm_name          = "alerta-de-erro-${var.name}-${count.index}"
    alarm_description   = "Detector de queda do alb do ${var.name}"

    actions_enabled = true

    comparison_operator = "GreaterThanOrEqualToThreshold"

    evaluation_periods  = 1
    datapoints_to_alarm = 1
    threshold           = 1

    alarm_actions       = [aws_sns_topic.alerta_de_erro[0].arn]

    metric_query {
        id = "criterio"

        label = "verifica a quantidade de hosts nao saudaveis"

        return_data = true

        period = 60

        expression = "SELECT MAX(UnHealthyHostCount) FROM SCHEMA(\"AWS/ApplicationELB\", AvailabilityZone,LoadBalancer,TargetGroup) WHERE LoadBalancer = '${split(":loadbalancer/", var.load_balancers[count.index])[1]}'"
    }

    tags = merge({
            Name = "${var.name}-alerta_de_erro-${count.index}"
        },
        var.tags
    )

    lifecycle {
        ignore_changes = [
            actions_enabled
        ]
    }
}

resource "aws_sns_topic" "alerta_de_erro" {
    count = var.load_balancers != null ? 1 : 0

    name = "alerta-de-erro-${var.name}"

    tags = merge({
            Name = "${var.name}-alerta_de_erro"
        },
        var.tags
    )
}

data "aws_iam_policy_document" "alerta_de_erro" {
    count = var.load_balancers != null ? 1 : 0

    statement {
        effect = "Allow"

        actions = [
            "SNS:Publish"
        ]

        principals {
            type        = "Service"
            identifiers = ["cloudwatch.amazonaws.com"]
        }

        resources = [
            aws_sns_topic.alerta_de_erro[count.index].arn
        ]

        condition {
            test = "ArnLike"

            variable = "aws:SourceArn"

            values = aws_cloudwatch_metric_alarm.alerta_de_erro.*.arn
        }
    }
}

resource "aws_sns_topic_policy" "alerta_de_erro" {
    count = var.load_balancers != null ? 1 : 0

    arn    = aws_sns_topic.alerta_de_erro[count.index].arn
    policy = data.aws_iam_policy_document.alerta_de_erro[count.index].json
}

resource "aws_sns_topic_subscription" "alerta_de_erro" {
    count = var.load_balancers != null ? 1 : 0

    topic_arn = aws_sns_topic.alerta_de_erro[count.index].arn
    endpoint  = aws_lambda_function.alerta_de_erro.arn
    protocol  = "lambda"
}

resource "aws_lambda_permission" "alerta_de_erro_lb" {
    count = var.load_balancers != null ? 1 : 0

    statement_id = "alerta-de-erro-${var.name}"
    action = "lambda:InvokeFunction"
    principal = "sns.amazonaws.com"
    function_name = aws_lambda_function.alerta_de_erro.arn
    source_arn = aws_sns_topic.alerta_de_erro[count.index].arn
}