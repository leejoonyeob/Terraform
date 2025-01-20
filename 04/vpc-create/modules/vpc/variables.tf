variable "vpc_id" {
    default = "10.0.0.0/16"
    description = "vpc_cidr"
    type = string
}

variable "vpc_tag" {
    default = {
        Name = "myvpc"
    }
    description = "VPC tag" 
    type = map(string)
}

variable "igw_tag" {
    default = {
        Name = "myigw"
    }
    description = "igw tag"
    type = map(string)
}

variable "vpc_subnet"{
    default = "10.0.1.0/24"
    description = "vpc Public Subnet"
}

variable "subnet_tag" {
    default = {
        Name = "mySubnet"
    }
    description = "Public Subnet Tag"
    type = map(string)
}

variable "route_table" {
    default = {
        Name = "route_table"
    }
    description = "Public route_table"
    type = map(string)
}