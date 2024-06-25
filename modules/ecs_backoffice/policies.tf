# Task role assume policy
data "aws_iam_policy_document" "task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Task logging privileges
data "aws_iam_policy_document" "task_permissions" {
  statement {
    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.ecs_cloudwatch_log_group.arn}:*",
    ]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketWebsite",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:ListMultipartUploadParts",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
    statement {
    effect = "Allow"

    resources = [
      "${var.s3-bucket}",
      "${var.s3-bucket}/*",
      "${aws_cloudwatch_log_group.ecs_cloudwatch_log_group.arn}:*"
    ]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketWebsite",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:ListMultipartUploadParts"
    ]
  }
 
}

# Task ecr privileges
data "aws_iam_policy_document" "task_execution_permissions" {
  statement {
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketWebsite",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:ListMultipartUploadParts",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "secretsmanager:GetSecretValue"
    ]
  }
  statement {
    effect = "Allow"

    resources = [
      "${var.s3-bucket}",
      "${var.s3-bucket}/*"
    ]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketWebsite",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:ListMultipartUploadParts"
    ]
  }

}



data "aws_iam_policy_document" "read_repository_credentials" {
  statement {
    effect = "Allow"

    resources = ["*"]

    actions = [
      "secretsmanager:GetSecretValue",
      ]
  }
}


