resource "aws_iam_role" "night_sleep" {
    name = "${local.name}-night-sleep"
    description = "role do night sleep"

    assume_role_policy = file("${path.module}/policy/night_sleep_role.json")

    tags = merge({
            Name = "${local.name}-night_sleep"
        },
        var.tags
    )
}

resource "aws_iam_policy" "night_sleep" {
    name        = "${local.name}-night-sleep"
    path        = "/"
    description = "politica com acesso a logs"

    policy = templatefile("${path.module}/policy/night_sleep_policy.json", {
        AUTO_SCALING_GROUPS = length(local.autoscaling_groups) > 0 ? "${jsonencode({"Effect": "Allow", "Action": "autoscaling:UpdateAutoScalingGroup", "Resource": local.autoscaling_groups})},": ""
        INSTANCE_IDS = length(local.instace_ids) > 0 ? "${jsonencode({"Effect": "Allow", "Action": ["ec2:StartInstances", "ec2:StopInstances"], "Resource": local.instace_ids})},": ""
        ECS_SERVICES = length(local.ecs_services) > 0 ? "${jsonencode({"Effect": "Allow", "Action": "ecs:UpdateService", "Resource": local.ecs_services})},": ""
        RDS_IDS = length(local.rds_ids) > 0 ? "${jsonencode({"Effect": "Allow", "Action": ["rds:StartDBInstance", "rds:StopDBInstance"], "Resource": local.rds_ids})},": ""
        LOG_ARN = aws_cloudwatch_log_group.night_sleep.arn
    })
}

resource "aws_iam_role_policy_attachment" "night_sleep" {
    role       = aws_iam_role.night_sleep.name
    policy_arn = aws_iam_policy.night_sleep.arn
}