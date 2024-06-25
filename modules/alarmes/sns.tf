resource "aws_sns_topic" "account_billing_alarm_topic" {
    name = "account-billing-alarm-topic"

    tags = merge(
        {
            Name        = "account_billing_alarm_topic"
        },
        var.tags
    )
}

resource "aws_sns_topic_policy" "account_billing_alarm_policy" {
    arn    = aws_sns_topic.account_billing_alarm_topic.arn
    policy = data.aws_iam_policy_document.sns_topic_policy.json
}