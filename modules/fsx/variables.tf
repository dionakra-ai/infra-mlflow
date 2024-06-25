variable "name" {
    type = string
}

variable "cidrs" {
    type = list(string)
}

variable "subnet_ids"{
    type = list

}

variable "storage_capacity"{
    type = number
    }
variable "throughput_capacity"{
    type = number
}

variable "deployment_type"{
    type = string
}



variable "backup"{
    type = string
}

variable "usernamefsx" {
  type = string
}

variable "passwordfsx" {
  type = string
}

variable "vpc_id"{
    type = string
}

variable "tags" {
  default     = {}
  type        = map(string)
}
variable "aliases"{
    type = list(string)
}