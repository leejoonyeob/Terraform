variable "instance_type" {
    type        = string
    default     = "t2.micro"
    description = "EC2 instance type"
}
variable "ec2_tag" {
    type        = map(string)
    default     = {
        Name = "myec2"
    }
    description = "EC2 instance tags"
}
#필수 입력 사항
variable "subnet_id" {
    type        = string
    description = "Subnet ID for EC2 instance"
}

variable "sg_ids" {
    type        = list(string)
    description = "Security Group IDs"
}

variable "keypair" {
    type        = string
    description = "EC2 keypair name"
}

