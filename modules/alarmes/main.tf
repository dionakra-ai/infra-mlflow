resource "aws_budgets_budget" "budget_account" {
  name              = "budget alarm"
  budget_type       = "COST"
  limit_amount      = var.limit_amount
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2020-01-01_00:00"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"

    subscriber_sns_topic_arns = [
      aws_sns_topic.account_billing_alarm_topic.arn
    ]
  }

  cost_types {
    include_credit             = false
    include_refund             = false
    use_blended                = false
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
  }

  depends_on = [
    aws_sns_topic.account_billing_alarm_topic
  ]
}

# baseado em
# https://rafaelribeiro.io/blog/billings-alarms-aws-using-terraform