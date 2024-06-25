resource "aws_iam_role" "execution" {
  name                 = "${var.cluster_name}_execution_ecs"
  assume_role_policy   = data.aws_iam_policy_document.task_assume.json
 
}

resource "aws_iam_role_policy" "task_execution" {
  name   = "${var.cluster_name}_task_execution_ecs"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.task_execution_permissions.json
  lifecycle {
    ignore_changes = [policy]
  }
}



resource "aws_iam_role" "task" {
  name                 = "${var.cluster_name}_task_ecs"
  assume_role_policy   = data.aws_iam_policy_document.task_assume.json
  
}

resource "aws_iam_role_policy" "log_agent" {
  name   = "${var.cluster_name}_log_agent_ecs"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_permissions.json
  lifecycle {
    ignore_changes = [policy]
  }
}
