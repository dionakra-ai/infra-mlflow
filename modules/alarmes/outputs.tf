output "sns_alert_topic" {
    value = aws_sns_topic.account_billing_alarm_topic.arn
}