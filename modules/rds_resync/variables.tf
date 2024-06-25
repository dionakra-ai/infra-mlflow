variable "target_account_id" {
    type = string
    description = "id da conta para onde o bd vai ser restaurado"
}

variable "base_account_id" {
    type = string
    description = "id da conta para usar de base para a restauracao do bd"
}

variable "base_rds_id" {
    type = string
    description = "nome do rds de base para a restauracao"
}

variable "target_rds_id" {
    type = string
    description = "nome do rds que vai ser restaurado. esse banco precisa estar criado para a lambda puxar os dados dele"
}

variable "base_account" {
    type = bool
    default = false
    description = "se eu sou a conta que vai ser usada como base do clone. a target account que recebe a restauracao"
}

variable "tags" {
    default     = {}
    type        = map(string)
    description = "tags adicionais para o lambda"
}

variable "gc_schedule" {
    type = string
    default = "cron(0 2 ? * MON-SUN *)"
    description = "expressao cron de quando o garbage collector de snapshots dispara"
}

data "aws_region" "region" {}

# data "aws_caller_identity" "current" {}
# account_id = data.aws_caller_identity.current.account_id

data "aws_db_instance" "target_database" {
    count = var.base_account ? 0 : 1

    db_instance_identifier = var.target_rds_id
}

locals {
    base_account_id = var.base_account_id
    target_account_id = var.target_account_id

    trusting_iam_arn = "arn:aws:iam::${local.target_account_id}:role/rds_sync_${var.target_rds_id}"
    trusted_iam_arn = "arn:aws:iam::${local.base_account_id}:role/rds_sync_${var.target_rds_id}"

    snapshot_arn = "arn:aws:rds:${data.aws_region.region.name}:${local.base_account_id}:snapshot:${var.base_rds_id}"

    base_rds_arn = "arn:aws:rds:${data.aws_region.region.name}:${local.base_account_id}:db:${var.base_rds_id}"
    target_rds_arn = "arn:aws:rds:${data.aws_region.region.name}:${local.target_account_id}:db:${var.target_rds_id}"

    base_option_group_arns = var.base_account ? [] : [for option in data.aws_db_instance.target_database[0].option_group_memberships : "arn:aws:rds:${data.aws_region.region.name}:${local.base_account_id}:og:${option}"]
    target_option_group_arns = var.base_account ? [] : [for option in data.aws_db_instance.target_database[0].option_group_memberships : "arn:aws:rds:${data.aws_region.region.name}:${local.target_account_id}:og:${option}"]

    target_parameter_group_arns = var.base_account ? [] : [for parameter in data.aws_db_instance.target_database[0].db_parameter_groups : "arn:aws:rds:${data.aws_region.region.name}:${local.target_account_id}:pg:${parameter}"]
    target_security_group_arns = var.base_account ? [] : [for sg in data.aws_db_instance.target_database[0].vpc_security_groups : "arn:aws:rds:${data.aws_region.region.name}:${local.target_account_id}:secgrp:${sg}"]
    target_subnet_group_arns = var.base_account ? [] : ["arn:aws:rds:${data.aws_region.region.name}:${local.target_account_id}:subgrp:${data.aws_db_instance.target_database[0].db_subnet_group}"]
}