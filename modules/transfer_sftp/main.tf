resource "aws_transfer_server" "sftp_server" {
  tags = {
    Name = "sftp_server"
  }

  endpoint_details {
    subnet_ids = var.subnet_ids
    vpc_id     = var.vpc_id
  }
  protocols   = ["SFTP"]

  identity_provider_type = "SERVICE_MANAGED"
  domain = "S3"
}