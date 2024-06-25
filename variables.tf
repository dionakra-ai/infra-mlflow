variable "vpc_id" {
  type = string
  description = "VPC Id"
}

variable "app_subnets" {
  type        = list(string)
  description = "List of private Subnets"
}

variable "db_subnets" {
  type        = list(string)
  description = "List of isolateds Subnets"
}

variable "project_name" {
  type = string
  description = "Project unique name"
  default = "ceia-mlflow"
}

variable "bucket_name" {
  type        = string
  description = "A unique name for this application (e.g. mlflow-team-name)"
  default = "dionakra-ceia-mlflow"
}

variable "db_name" {
  type        = string
  description = "Name of RDS DB"
  default = "mlflowdb"
}

variable "db_user" {
  type        = string
  description = "Name of RDS User"
  default = "master"
}

variable "db_port" {
  type        = number
  description = "Port of RDS Server"
  default = 3306
}