# variable "cold_storage_after" {
#     type = number
#     default = 30
# }

# variable "delete_after" {
#     type = number
#     default = 60
# }

# variable "changeable_for_days" {
#     type = number
#     default = 1
# }

# variable "max_retention_days" {
#     type = number
#     default = 60
# }

# variable "min_retention_days" {
#     type = number
#     default = 30
# }

# variable "resource_type_opt_in_preference" {
#     type = map(bool)
#     default = {
#         "RDS" = true
#     }
# }

variable "tags" {
    default     = {}
    type        = map(string)
    description = "Extra tags to attach to the VPC resources"
}