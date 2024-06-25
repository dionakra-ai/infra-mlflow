variable "name" {
    type = string
    default = "main"
    description = "nome da funcao"
}

variable "log_group_names" {
    type = list(string)
    default = null
    description = "lista com os grupos de logs para monitorar. todas verificam a mesma filter_pattern"
}

variable "load_balancers" {
    type = list(string)
    default = null
    description = "os arns dos load balancers para coletar metricas e avisar em caso de falha"
}

variable "filter_pattern" {
    default = "?ERROR ?WARN ?5xx"
    type = string
    description = "padrao no log que dispara a mensagem de erro"
}

variable "bot_image" {
    type = string
    description = "url da imagem do bot de alerta de discord"
}

variable "alert_hook" {
    type = string
    description = "webhook do canal do bot de alerta de discord"
}

variable "tags" {
    default     = {}
    type        = map(string)
    description = "tags adicionais para o modulo"
}

data "aws_region" "region" {}

data "aws_caller_identity" "current" {}