variable "limit_amount" {
    type = number
}

variable "tags" {
    default     = {}
    type        = map(string)
    description = "tags adicionais para o alarme"
}