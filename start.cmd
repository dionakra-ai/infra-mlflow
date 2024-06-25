SET AWS_DEFAULT_REGION=us-east-1
terraform init -force-copy -input=false -backend-config bucket=dionakra-terraform-state -backend-config dynamodb_table=dionakra-terraform-state
terraform workspace new production
terraform workspace select production


terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars"
