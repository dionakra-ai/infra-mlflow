variable "ami" {
    type = string
}

variable "name" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "metadata" {
    type = bool
    default = false
    description = "libera o endpoint de metadados da instancia. potencial risco: NAO libere ele a menos que pretenda usar."
}

variable "http_tokens" {
    type = string
    default = "required"
    description = "requer token de autenticacao caso o endpoint de metadados esteja habilitado. mantenha precisando dele se nao for estritamente necessario tirar."
}

variable "subnets" {
    type = list(string)
}

variable "monitoring" {
    type = bool
    default = true
    description = "liga a coleta de dados mais detalhada da ec2 pelo cloudwatch"
}

variable "security_groups" {
    type = list(string)
}

variable "desired_capacity" {
    type = number
    default = 1
}

variable "min_size" {
    type = number
    default = 0
}

variable "max_size" {
    type = number
    default = 1
}

variable "ebs_optimized" {
    type = bool
    default = true
    description = "liga a otimizacao de ebs. pode ser incpompativel com algumas configuracoes de rede, ou de escala. na duvida, mantenha verdadeiro."
}

variable "policy_file" {
    # type = object({
    #     file_path = string
    #     arguments = object({})
    # })

    default = null
}

variable "user_data" {
    type = string
    default = null
}

variable "tags" {
    default     = {}
    type        = map(string)
    description = "tags extras para a ec2"
}