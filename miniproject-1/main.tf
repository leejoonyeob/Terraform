# 0. provier 설정 - provider.tf
#################################
# 기본 인프라 구성                
#################################
# 1. VPC 설정
# 2. Public subnet 설정 -> 퍼블릭 IPv4 주소 자동 할당, 가용영역 선택
# 3. Internet Gateway 설정
# 4. Public Routing 설정
# 5. Public Routing Table Association(Public subnet <-> Public Routing) 설정
##################################
# EC2 인스턴스 생성 
##################################
# 1. Public Security Group 설정
# 2. AMI Data Source 설정
# 3. SSH Key 생성
# 4. EC2 Instance 생성


#### 기본 인프라 구성 ####
# 1. VPC 설정
resource "aws_vpc" "myvpc" {
  cidr_block = "10.123.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "myVPC"
  }
}
# 2. Public subnet 설정
resource "aws_subnet" "public_SN" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.123.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSN"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# 3. Internet Gateway 설정
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myIGW"
  }
}
# 4. Public Routing 설정
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = aws_vpc.myvpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myRT"
  }
}
# 5. Public Routing Table Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_SN.id
  route_table_id = aws_route_table.public_RT.id
}

#### EC2 인스턴스 생성 ####
# 1. Public Security Group 설정
resource "aws_security_group" "public_SG" {
  name        = "mySG"
  description = "Allow SSH,HTTP,HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH" {
  security_group_id = aws_security_group.public_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP" {
  security_group_id = aws_security_group.public_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS" {
  security_group_id = aws_security_group.public_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.public_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 2. AMI Data Source 설정
data "aws_ami" "ubuntu2404" {
  most_recent = true
  # 소유자 계정 ID
  owners = ["099720109477"]   

  filter {
    # AMI 이름
    name = "name"    
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
# 3. SSH Key 생성
resource "aws_key_pair" "ljy_auth" {
  key_name   = "ljykey"
  public_key = file("~/.ssh/ljykey.pub")
}
# 4. EC2 Instance 생성
resource "aws_instance" "dev-server" {
  ami           = data.aws_ami.ubuntu2404.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.ljy_auth.id

  vpc_security_group_ids = [aws_security_group.public_SG.id]

  subnet_id = aws_subnet.public_SN.id

  user_data_replace_on_change = true
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

 provisioner "local-exec" {
    command = templatefile("sshconfig.tpl", { 
      hostname = self.public_ip,
      identityfile = var.identity_file,
      username = "ubuntu"
      })
    interpreter = [ "/bin/bash", "-c" ]
  }

  tags = {
    Name = "My Dev Server"
  }
}
