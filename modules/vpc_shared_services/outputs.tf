output "vpc_id" {
    value = aws_vpc.sharedservices_vpc.id
}


output "private_subnets_cidr_list" {
    value = var.private_subnets.subnet.*.cidr_block
}

output "private_subnets_cidr" {
    value = var.private_subnets.cidr_base
}

output "private_subnets_id" {
    value = aws_subnet.private.*.id
}

output "public_subnets_cidr_list" {
    value = var.public_subnets.subnet.*.cidr_block
}

output "public_subnets_cidr" {
    value = var.public_subnets.cidr_base
}

output "public_subnets_id" {
    value = aws_subnet.public.*.id
}

output "route_tables" {

    value = setunion(aws_route_table.public.*.id,aws_route_table.private.*.id)

}
output "route_tables_to_trasitgateway" {

    value = aws_route_table.private.*.id

}


output "subnets_ids" {

    value = setunion(aws_subnet.public.*.id,aws_subnet.private.*.id)

}

