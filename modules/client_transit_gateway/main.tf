
##UTILIZANDO O PROFILE COM CREDENCIAIS DA CONTA ROUTING##
provider "aws" {
  alias = "routing"
  region     = var.region
  profile = "routing"
}



data "aws_caller_identity" "tg_caller" {
}

##CONECTANDO NO S3 PARA CHEGAR NO REMOTE STATE DA CONTA DE ROUTING PARA COLETAR AS INFORMAÇÕES DO TRANSIT GATEWAY##
data "terraform_remote_state" "routing" {
  backend = "s3"
  config = {
    bucket = "midnight-routing-production"
    region = "us-east-1"
    key = "infra/aws/midnight/production/terraform.tfstate"
    profile = "routing"
  }
}

##REALIZANDO O COMPARTILHAMENTO DO RECURSO DO TRANSIT GATEWAY PARA A CONTA UTILIZANTE DO MODULO##
resource "aws_ram_principal_association" "tg_ram_principal" {
 
  provider = aws.routing

  principal          = data.aws_caller_identity.tg_caller.account_id
  resource_share_arn = data.terraform_remote_state.routing.outputs.ram_tg_routing_id
}

##ATTACHMENT DA VPC DA CONTA UTILIZANTE DO MODULO NO TRANSIT GATEWAY##
resource "aws_ec2_transit_gateway_vpc_attachment" "tg_attachment" {

  depends_on = [
    aws_ram_principal_association.tg_ram_principal,
    data.terraform_remote_state.routing
  ]

  subnet_ids         = var.subnets_attachment ##IDS DAS SUBNETS DE APP OU PRIVATE(3 SUBNETS)##
  transit_gateway_id = data.terraform_remote_state.routing.outputs.tgw_routing_id
  vpc_id             = var.vpc_id

  tags = {
    Name = "tgw_attachment"
   }
}
##ACEITE DO ATTACHMENT DE VPC NO TRANSIT GATEWAY##
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "accepter" {
  
  provider = aws.routing

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tg_attachment.id

  tags = {
    Name = "tgw-accepter"
  }
}
##CRIANDO LISTA COM UNIAO DOS IDS DAS TABELAS DE ROTEAMENTO(VAR.ROUTES_TABLES)+ROTAS(VAR.ROUTES) QUE TERAO ROTAS DISPONIVEIS NA CONTA UTILIZANTE DO MODULO##
locals {
  route_tables = setproduct(setunion(var.route_tables),var.routes)
  route_tables2 = setproduct(setunion(var.route_tables),var.routes_vpn)
  
}

##CRIANDO ROTAS PARA AS REDES DECLARADAS EM VAR.ROUTES##
resource "aws_route" "to_routing" {
   depends_on = [
    data.terraform_remote_state.routing,
    aws_ec2_transit_gateway_vpc_attachment_accepter.accepter,

  ]
  count = length(local.route_tables)
  
  route_table_id            = tolist(local.route_tables)[count.index][0]##PRIMEIRO ITEM DA LISTA ROUTE_TABLES QUE TRAZ OS IDS DASTABELAS DE ROTAS DE TODAS SUBNETS##
  destination_cidr_block    = tolist(local.route_tables)[count.index][1]##SEGUNDO ITEM DA LISTA ROUTE_TABLES QUE TRAZ AS REDES DECLARADAS EM VAR.ROUTES##
  transit_gateway_id = data.terraform_remote_state.routing.outputs.tgw_routing_id ##DESTINO PARA O TRANSIT GATEWAY NA CONTA ROUTING
}

resource "aws_route" "to_routing_vpnazure" {
   depends_on = [
    data.terraform_remote_state.routing,
    aws_ec2_transit_gateway_vpc_attachment_accepter.accepter,

  ]
  count = length(local.route_tables2)
  
  route_table_id            = tolist(local.route_tables2)[count.index][0]##PRIMEIRO ITEM DA LISTA ROUTE_TABLES QUE TRAZ OS IDS DAS TABELAS DE ROTAS DE TODAS SUBNETS##
  destination_cidr_block    = tolist(local.route_tables2)[count.index][1]##SEGUNDO ITEM DA LISTA ROUTE_TABLES QUE TRAZ AS REDES DECLARADAS EM VAR.ROUTES##
  transit_gateway_id = data.terraform_remote_state.routing.outputs.tgw_routing_id ##DESTINO PARA O TRANSIT GATEWAY NA CONTA ROUTING
}


##CRIACAO DE ROTAS PARA A INTERNET COM O DESTINO TRANSITGATEWAY PARA TODAS AS SUBNETS PRIVADAS
resource "aws_route" "internet_to_transitgateway" {
   depends_on = [
    data.terraform_remote_state.routing,
    aws_ec2_transit_gateway_vpc_attachment_accepter.accepter,

  ]
  count = length(var.route_tables_to_trasitgateway)
  
  route_table_id            = var.route_tables_to_trasitgateway[count.index]
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id = data.terraform_remote_state.routing.outputs.tgw_routing_id
}

