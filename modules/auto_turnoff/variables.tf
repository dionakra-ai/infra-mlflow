variable name {
    type = string
    description = "nome para identificar os recursos."
    default = null
}

variable sleep {
    type = string
    default = null
    description = "o cron, em utc, do momento que a maquina vai desligar"
}

variable wake_up {
    type = string
    default = null
    description = "o cron, em utc, do momento que a maquina vai ligar"
}

variable target_id {
    type = list(string)
    description = "lista com os nomes dos grupos de autoescala ou instancias que vai usar"
    default = []
}

variable rds_id {
    type = list(string)
    description = "lista com os nomes dos rds que vai usar"
    default = []
}

variable cpu_idle_sleep {
    description = "parametros do desligamento por falta de uso"
    type = object({
        threshold = number
        datapoints_to_alarm = number
        evaluation_periods = number
    })
    default = null
}

variable "timeout" {
    type = number
    description = "timeout do lambda"
    default = 600
}

variable "tags" {
    default     = {}
    type        = map(string)
    description = "tags adicionais para o modulo"
}

data "aws_region" "region" {}

data "aws_caller_identity" "current" {}

locals {
    region = data.aws_region.region.name

    account_id = data.aws_caller_identity.current.account_id

    name = var.name != null ? var.name : var.target_id[0]

    ecs_services = [for data in var.target_id : data if substr(data, 0, 11) == "arn:aws:ecs" && substr(data, 0, 2) != "i-"]

    autoscaling_groups = [for data in var.target_id : "arn:aws:autoscaling:${local.region}:${local.account_id}:autoScalingGroup:*:autoScalingGroupName/${data}" if substr(data, 0, 11) != "arn:aws:ecs" && substr(data, 0, 2) != "i-"]

    instace_ids = [for data in var.target_id : "arn:aws:ec2:${local.region}:${local.account_id}:instance/${data}" if substr(data, 0, 11) != "arn:aws:ecs" && substr(data, 0, 2) == "i-"]

    rds_ids = [for data in var.rds_id : "arn:aws:rds:${local.region}:${local.account_id}:db:${data}"]
}