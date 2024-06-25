resource "aws_iam_role" "trusted_account_rds_sync" {
    count = var.base_account ? 1 : 0

    name = "rds_sync_${var.target_rds_id}"
    description = "conta que faz a restauracao do rds"

    assume_role_policy = file("${path.module}/trusted_role.json")

    tags = merge(
        {
            Name        = "rds_sync_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_iam_policy" "trusted_account_rds_sync" {
    count = var.base_account ? 1 : 0

    name        = "rds_sync_${var.target_rds_id}"
    path        = "/"
    description = "politica do restaurador de resync que faz a restauracao"

    policy = templatefile("${path.module}/trusted_policy.json", {
        TRUSTING_IAM_ARN = local.trusting_iam_arn,
        BASE_RDS_SNAPSHOT_ARN = local.snapshot_arn
        BASE_RDS_DB_ARN = local.base_rds_arn
        LOG_ARN = aws_cloudwatch_log_group.rds_resync[count.index].arn
    })

    tags = merge(
        {
            Name = "rds_sync_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_iam_role_policy_attachment" "trusted_account_rds_sync" {
    count = var.base_account ? 1 : 0

    role       = aws_iam_role.trusted_account_rds_sync[count.index].name
    policy_arn = aws_iam_policy.trusted_account_rds_sync[count.index].arn
}

data "archive_file" "rds_resync" {
    count = var.base_account ? 1 : 0

    type             = "zip"
    source_file      = "${path.module}/main.py"
    output_path      = "${path.module}/main.zip"
}

resource "aws_cloudwatch_log_group" "rds_resync" {
    count = var.base_account ? 1 : 0

    name              = "/aws/lambda/${aws_lambda_function.rds_resync[count.index].function_name}"
    retention_in_days = 180

    tags = merge({
            Name = "rds_sync_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_lambda_function" "rds_resync" {
    count = var.base_account ? 1 : 0

    function_name = "rds_sync_${var.target_rds_id}"

    description = "faz o sync dos bancos de dados em duas contas diferentes. o base sera clonado para o alvo"

    filename = data.archive_file.rds_resync[count.index].output_path

    source_code_hash = data.archive_file.rds_resync[count.index].output_base64sha256

    handler = "main.main"
    runtime = "python3.9"

    role = aws_iam_role.trusted_account_rds_sync[count.index].arn

    timeout = 900

    environment {
        variables = {
            SOURCE_ACCOUNT_ID = local.base_account_id
            DESTINATION_ACCOUNT_ID = local.target_account_id
            SOURCE_INSTANCE_ID = var.base_rds_id
            TARGET_INSTANCE_ID = var.target_rds_id
            TARGET_ACCOUNT_ROLE_ARN = local.trusting_iam_arn
        }
    }

    tags = merge({
            Name = "rds_sync_${var.target_rds_id}"
            application = "rds_resync",
            role = "api"
        },
        var.tags
    )
}

resource "aws_lambda_function_event_invoke_config" "rds_resync" {
    count = var.base_account ? 1 : 0

    function_name = aws_lambda_function.rds_resync[count.index].function_name

    maximum_retry_attempts = 0
}

# -----------------------------------------------------------------

resource "aws_iam_role" "rds_sync_gc" {
    count = var.base_account ? 1 : 0

    name = "rds_sync_gc_${var.target_rds_id}"
    description = "role de limpar os snapshots deixados pelo resync"

    assume_role_policy = file("${path.module}/rds_sync_gc_role.json")

    tags = merge(
        {
            Name        = "rds_sync_gc_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_iam_policy" "rds_sync_gc" {
    count = var.base_account ? 1 : 0

    name        = "rds_sync_gc_${var.target_rds_id}"
    path        = "/"
    description = "politica da lambda de limpar os snapshots do resync"

    policy = templatefile("${path.module}/rds_sync_gc_policy.json", {
        BASE_RDS_SNAPSHOT_ARN = local.snapshot_arn
        BASE_RDS_DB_ARN = local.base_rds_arn
        LOG_ARN = aws_cloudwatch_log_group.rds_resync_gc[count.index].arn
    })

    tags = merge(
        {
            Name = "rds_sync_gc_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_iam_role_policy_attachment" "rds_sync_gc" {
    count = var.base_account ? 1 : 0

    role       = aws_iam_role.rds_sync_gc[count.index].name
    policy_arn = aws_iam_policy.rds_sync_gc[count.index].arn
}

data "archive_file" "rds_resync_gc" {
    count = var.base_account ? 1 : 0

    type             = "zip"
    source_file      = "${path.module}/main_gc.py"
    output_path      = "${path.module}/main_gc.zip"
}

resource "aws_cloudwatch_log_group" "rds_resync_gc" {
    count = var.base_account ? 1 : 0

    name              = "/aws/lambda/${aws_lambda_function.rds_resync_gc[count.index].function_name}"
    retention_in_days = 180

    tags = merge({
            Name = "rds_sync_gc_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_lambda_function" "rds_resync_gc" {
    count = var.base_account ? 1 : 0

    function_name = "sync_garbage_collector_${var.target_rds_id}"

    description = "limpa os snapshots deixados pelas lambdas de resync"

    filename = data.archive_file.rds_resync_gc[count.index].output_path

    source_code_hash = data.archive_file.rds_resync_gc[count.index].output_base64sha256

    handler = "main_gc.main"
    runtime = "python3.9"

    role = aws_iam_role.rds_sync_gc[count.index].arn

    environment {
        variables = {
            SOURCE_ACCOUNT_ID = local.base_account_id
            SOURCE_INSTANCE_ID = var.base_rds_id
        }
    }

    tags = merge({
            Name = "rds_sync_${var.target_rds_id}"
            application = "rds_resync_gc",
            role = "api"
        },
        var.tags
    )
}

resource "aws_lambda_function_event_invoke_config" "rds_resync_gc" {
    count = var.base_account ? 1 : 0

    function_name = aws_lambda_function.rds_resync_gc[count.index].function_name

    maximum_retry_attempts = 0
}

resource "aws_cloudwatch_event_rule" "rds_resync_gc" {
    count = var.base_account ? 1 : 0

    name                = "rds_resync_gc_${var.target_rds_id}"
    description         = "liga a maquina"

    schedule_expression = var.gc_schedule

    tags = merge({
            Name = "rds_resync_gc_${var.target_rds_id}"
        },
        var.tags
    )
}

resource "aws_cloudwatch_event_target" "rds_resync_gc" {
    count = var.base_account ? 1 : 0

    rule = aws_cloudwatch_event_rule.rds_resync_gc[count.index].name

    arn = aws_lambda_function.rds_resync_gc[count.index].arn
}

resource "aws_lambda_permission" "rds_resync_gc" {
    count = var.base_account ? 1 : 0

    statement_id = "rds_resync_gc_${var.target_rds_id}"
    action = "lambda:InvokeFunction"
    principal = "events.amazonaws.com"
    function_name = aws_lambda_function.rds_resync_gc[count.index].function_name
    source_arn = aws_cloudwatch_event_rule.rds_resync_gc[count.index].arn
}