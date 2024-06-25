variable "name" {
    type = string
    description = "nome do parametro. escreva no nome como path para facilitar as buascas"
}

variable "description" {
    type = string
    description = "descreva para que serve o parametro"
}

variable "policy" {
    type = string
    default = null
    description = "a politica para a chave de kms que cifra o parametro"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "tags extras para a parameter store"
}