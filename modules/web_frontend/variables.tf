variable "bucket_name" {
    type = string
}

variable "default_root_object" {
    type = string
    default = "index.html"
    description = "arquivo padrao que e servido ao entrar no site"
}

variable "urls" {
    type = list(string)
    default = null
    description = "cnames alternativos para o cloudfront. usar em conjunto com o acm_certificate_arn"
}

variable "acm_certificate_arn" {
    type = string
    default = null
    description = "certificado proprio para usar no cloudfront em ves de usar o fornecido por eles. (usar em conjunto com cname alternativo)."
}

variable "min_ttl" {
    type = number
    default = 0
    description = "valor minimo do ttl do cache"
}

variable "max_ttl" {
    type = number
    default = 0
    description = "valor maximo do ttl do cache"
}

variable "default_ttl" {
    type = number
    default = 0
    description = "valor padrao do ttl do cache"
}

variable "enable_custom_error_response" {
    type = bool
    default = false
    description = "libera uma resposta propria para as paginas de erro. a configuracao padrao para esse pacote, e permitir o funcionamento de spas. configure as demais opcoes se nao for seu caso"
}

variable "custom_error_response_error_caching_min_ttl" {
    type = number
    default = 0
    description = "tempo de ttl do cache de repostas em caso de erro. na duvida, nao uso. pode ser bem grande em caso de paginas estaticas. invalidacao de cache pode ser necessario em caso de deploy se configurar isso."
}

variable "custom_error_response_error_code" {
    type = number
    default = 403
    description = "qual codigo de erro que eu devo modificar"
}

variable "custom_error_response_response_code" {
    type = number
    default = 200
    description = "o novo codigo de erro a ser enviado"
}

variable "custom_error_response_response_page_path" {
    default = "/index.html"
}

variable "geo_restriction_restriction_type" {
    type = string
    default = "none"
    description = "tipo derestricao geografica a ser aplicada. padrao nenhuma"
}

variable "geo_restriction_locations"{
    type = list(string)
    default = []
    description = "locais onde aplicar a restricao de localizacao. padrao nenhum"
}

variable "price_class" {
    type = string
    default = "PriceClass_100"
    description = "classe de preco do servico do cloud front. ele determina a 'potencia' do servidor, e onde sera alocado. confira a tabela da aws"
}

variable "tags" {
    type        = map(string)
    default     = {}
    description = "tags adicionais para o front"
}