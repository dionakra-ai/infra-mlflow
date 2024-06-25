resource "aws_kms_key" "backup_vault" {
    description = "chave pra backups no aws vault"

    tags = merge(
        {
            Name = "vault_key"
        },
        var.tags
    )
}