variable "name" {
    type = string
}

variable "iam_database_authentication_enabled" {
    type = bool
    default = true
}

variable "engine" {
    type = string
}

variable "engine_version" {
    type = string
}

variable "charset_name" {
    type = string
}

variable "instance_class" {
    type = string
    default = "db.t3.micro"
}
variable "iops" {
    type = number
    default = null
    
}

variable "db_name" {
    type = string
    default = null
    description = "nome do banco de dados inicial"
}

variable "allocated_storage" {
    type = number
    default = 1
}

variable "max_allocated_storage" {
    type = number
    default = 2001
}

variable "vpc_id" {
    type = string
    
}

variable "vpc_security_group_ids" {
    type = list(string)
    default = []
}

variable "subnet_ids" {
    type = list
}
variable "availability_zone" {
    type = string
    default = null
}

variable "multi_az" {
    type = bool
    default = true
}

variable "license_model" {
    type = string
    default = "license-included"
}

variable "storage_type" {
    type = string
    default = "io1"
}

variable "backup_retention_period" {
    type = number
    default = null
}

variable "delete_automated_backups" {
    type = bool
    default = null
}

variable "backup_window" {
    type = string
    default = null
}

variable "skip_final_snapshot" {
    type = bool
    default = false
}

variable "final_snapshot_identifier" {
    type = string
    default = "backup-final"
}

variable "maintenance_window" {
    type = string
}

variable "deletion_protection" {
    type = bool
    default = true
}

variable "enabled_cloudwatch_logs_exports" {
    type = bool
    default = true
}

variable "tags" {
    default     = {}
    type        = map(string)
    description = "Extra tags to attach to the VPC resources"
}

variable "user" {
    type = string
}

variable "password" {
    type = string
}

variable "port" {
    type = number  
}

variable "cidr_base" {
    type = string

}

variable "identifier" {
    type = string
}

variable "rules" {
    type = list(string)
    
        }

variable "monitoring_interval" {
  type = number
  default = 0
}

variable "performance_insights_enabled" {
  type = bool
  default = false  
}