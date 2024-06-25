module "ecs-mlflow"  {
    source = "./modules/ecs"

    cluster_name = var.project_name
    vpc_id = var.vpc_id
    services = [
        {
            name = "${var.project_name}"
            memory = 512
            cpu = 256
            ports = [5000]
            subnet_ids = var.app_subnets
            environment_variables = [
                {
                    "name" = "BUCKET"
                    "value" = "s3://${var.bucket_name}"
                },
                {
                    "name" = "CONNECTION_STRING"
                    "value" = "mysql+pymysql://${var.db_user}:${random_password.db_password.result}@${aws_db_instance.mlflowdb.endpoint}/${var.db_name}"
                }
            ]
            security_options = {
                linux_parameters = null
                read_only = false
            }
            iam_policy = templatefile("${path.module}/policies/ecs/${var.project_name}.json", {
                BUCKET_NAME = var.bucket_name
            })
            discovery_service = true
#            load_balancers = {
#                subnet_ids = var.app_subnets
#                internal = true
#                target_port = 5000
#                health_check = {
#                    enabled = true
#                    port = 5000
#                    matcher = "200-399"
#                    path = "/"
#                    timeout = 30
#                    interval = 60
#                }
#            }
        }
    ]
}