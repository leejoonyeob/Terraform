variable "instance_type" {
    default = "t2.micro"
    description = "Instance Type"
}
variable "ec2_tag" {
    default ={
        Name = "myec2"
    }
    description = "EC@ instance Tag"
    type = map(string)

}
#필수 입력 사항
variable "subnet_id" {
    description = "subnet ID"
    type = string
}