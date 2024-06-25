resource "aws_launch_template" "ec2_launch_template" {
    name_prefix          = var.name
    image_id             = var.ami

    vpc_security_group_ids = var.security_groups

    instance_type        = var.instance_type

    dynamic iam_instance_profile {
        for_each = var.policy_file != null ? [true] : []

        content {
            name = aws_iam_instance_profile.ec2_instance_profile[0].name
        }
    }

    monitoring {
        enabled = var.monitoring
    }

    ebs_optimized = var.ebs_optimized

    metadata_options {
        http_endpoint = var.metadata == false || var.metadata == null ? "disabled" : "enabled"
        http_tokens = var.http_tokens
    }

    user_data = var.user_data

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "autoscaling_group" {
    name                      = "${var.name}_autoscaling_group"
    vpc_zone_identifier       = var.subnets

    desired_capacity          = var.desired_capacity
    min_size                  = var.min_size
    max_size                  = var.max_size

    health_check_grace_period = 5
    health_check_type         = "EC2"

    launch_template {
        id = aws_launch_template.ec2_launch_template.id
    }

    tag {
        key   = "Name"
        value = var.name
        propagate_at_launch = true
    }

    lifecycle {
        ignore_changes = [desired_capacity]
        create_before_destroy = true
    }
}