variable "instance" {
    type = object({
    name = string
    region = string
    vpc_id = string
    ami = string
    instance_type = string
    subnet_id = string
    public_ip = bool
    key_name = string
    
    private_ips_mode = bool
    instance_so = string
    private_ips = list(string)
    ebs = object({
       delete_on_termination = bool
       volume_size = number
       volume_type = string
       }
    )
      
        })
  
}
variable "rules" {
    type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_block = list(string)
    }))
  
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}

variable "account" {
  type = string
}

variable "backup" {
  type = string
}

variable "ebs_block_device" {
  description = "Map containing ebs configuration."
  type        = map(string)
  default     = {}
}

variable "iam_role_profile" {
  type = string
  default = null
}

variable "iops"{
type = string
default = null
}

