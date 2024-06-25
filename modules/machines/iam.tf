resource "aws_iam_policy" "ec2_instance_policy" {
    count = var.policy_file != null ? 1 : 0

    name        = var.name
    path        = "/"
    description = "IAM policy for ec2"

    policy = templatefile(var.policy_file.file_path, var.policy_file.arguments)
}

resource "aws_iam_role" "ec2_instance_role" {
    count = var.policy_file != null ? 1 : 0

    name               = var.name
    assume_role_policy = file("${path.module}/ec2_instance_role.json")

    tags = merge(
        {
            Name        = var.name
        },
        var.tags
    )
}

resource "aws_iam_role_policy_attachment" "ec2_instance_attachment" {
    count = var.policy_file != null ? 1 : 0

    role       = aws_iam_role.ec2_instance_role[count.index].name
    policy_arn = aws_iam_policy.ec2_instance_policy[count.index].arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    count = var.policy_file != null ? 1 : 0

    name = var.name
    role = aws_iam_role.ec2_instance_role[count.index].name

    tags = merge(
        {
            Name        = var.name
        },
        var.tags
    )
}