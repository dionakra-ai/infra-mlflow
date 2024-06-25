variable subnets_attachment {
  type = list(string)
  description = "IDS DAS SUBNETS DE APP OU PRIVATE PARA ADICIONAR NO ATTACHMENT DA VPC DO TRANSIT GATEWAY"  
}

variable route_tables {
  type = list
  description = "UTILIZADA PARA AGRUPAR LISTA DE IDS DAS SUBNETS+REDES QUE A CONTA UTILIZANTE DO MODULO IRA TER ROTA "
}

variable route_tables_to_trasitgateway{
  type = list
  description = "LISTA DE REDES PRIVADAS PARA CRIAR ROTA PARA A INTERNET COM O DESTINO TRANSIT GATEWAY"
}


variable routes {
  type = list
  description = "LISTA DE ROTAS QUE A CONTA UTILIZANTE TERÁ ACESSO"
}

variable routes_vpn {
  type = list
  description = "LISTA DE ROTAS QUE A CONTA UTILIZANTE TERÁ ACESSO"
}


variable vpc_id {
  type = string
  description = "VPC ID DA CONTA UTILIZANTE"
}


variable region {
  type = string
  description = "REGIAO UTILIZADA (SEMPRE US-EAST-1)"
}
