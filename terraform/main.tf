# Definindo o provedor AWS
provider "aws" {
  region = "us-east-1"  # Altere para a região desejada
}

# Criando uma sub-rede dentro da VPC
resource "aws_subnet" "my_subnet" {
  vpc_id            = "vpc-012b1ed5a7f10b849"
  cidr_block        = "172.31.0.0/16"  
  availability_zone = "us-east-1a"   

  tags = {
    Name = "subnet-terraform"
  }
}


# Criando uma tabela de roteamento para a sub-rede
resource "aws_route_table" "my_route_table" {
  vpc_id = "vpc-012b1ed5a7f10b849"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0c1199e975cfb0186"
  }

  tags = {
    Name = "route-table-terraform"
  }
}

# Associando a tabela de roteamento à sub-rede
resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_security_group" {
  name        = "launch-wizard-2"
  description = "launch-wizard-2 created 2024-04-01T05:31:19.154Z"
  vpc_id      = "vpc-012b1ed5a7f10b849"
}

resource "aws_security_group_rule" "all_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # Todos os protocolos
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_security_group_rule" "all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # Todos os protocolos
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}


# Criando uma instância EC2
resource "aws_instance" "my_instance" {
  ami                          = "ami-0c101f26f147fa7fd"
  instance_type                = "t2.micro"
  key_name                     = "my-ssh-key"
  associate_public_ip_address  = true
  security_groups              = [aws_security_group.my_security_group.id] 
  subnet_id                    = aws_subnet.my_subnet.id

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "ec2-teste-devops"
  }
}

# Output do endereço IP público
output "public_ip" {
  value = aws_instance.my_instance.public_ip
}
