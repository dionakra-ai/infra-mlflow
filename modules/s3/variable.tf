variable "name" {
    type = string
}

variable "acl" {
    type = string
}

variable "versioning" {
  type = string
}
variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}