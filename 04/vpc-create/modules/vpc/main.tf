# vpc 생성 
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags       = var.vpc_tag
}
# IGW 생성 및 연결
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags   = var.igw_tag
}
# Public Subnet 생성
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.vpc_subnet
  tags       = var.subnet_tag
}
# PUblic Routing Table 생성
resource "aws_route_table" "my_pubroute_table" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = var.route_table
}
resource "aws_route_table_association" "myassoc" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.my_pubroute_table.id
}

# PUblic Routing Table Default Route 설정