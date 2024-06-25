data "archive_file" "night_sleep" {
    type             = "zip"
    source_file      = "${path.module}/set_capacity.py"
    output_path      = "${path.module}/set_capacity.zip"
}

resource "aws_lambda_function" "night_sleep" {
    function_name = "night_sleep_${local.name}"

    filename = data.archive_file.night_sleep.output_path

    source_code_hash = data.archive_file.night_sleep.output_base64sha256

    handler = "set_capacity.main"
    runtime = "python3.9"

    role = aws_iam_role.night_sleep.arn

    timeout = var.timeout

    environment {
        variables = {
            TARGET_IDS = jsonencode(var.target_id)
            RDS_IDS = jsonencode(var.rds_id)
        }
    }

    tags = merge({
            Name = "${local.name}-night_sleep"
        },
        var.tags
    )
}

resource "aws_lambda_function_event_invoke_config" "night_sleep" {
    function_name = aws_lambda_function.night_sleep.function_name

    maximum_retry_attempts = 0
}