# Definindo o provedor AWS
provider "aws" {
  region = "us-east-1"  
}

resource "aws_vpc" "vpc_terraform" {
  cidr_block           = "172.16.0.0/24"

  tags = {
    Name        = "vpc-terraform"

  }
}

# Criando uma sub-rede dentro da VPC
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.vpc_terraform.id
  cidr_block        = "172.16.0.0/26"  
  availability_zone = "us-east-1a"   

  tags = {
    Name = "subnet-terraform"
  }
}

/*==== Subnets ======*/
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc_terraform.id
  tags = {
    Name        = "igw-teste"

  }
}

# Criando uma tabela de roteamento para a sub-rede
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.vpc_terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
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
  vpc_id      = aws_vpc.vpc_terraform.id
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
    Name = "ec2-teste-devops-vpc"
  }
}

# Output do endereço IP público
output "public_ip" {
  value = aws_instance.my_instance.public_ip
}
