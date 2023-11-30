resource "aws_key_pair" "mini_project" {
  key_name   = "mini_project"
  public_key = file("~/.ssh/cloud2024.pem.pub")
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    name = "${var.prefix}-vpc"
    }
  }


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-rtb"
  }
}

resource "aws_route_table_association" "rta" {
  for_each = var.subnets
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.rt.id
}

module "security-groups" {
  source          = "app.terraform.io/sanjarbey/security-groups/aws"
  version         = "2.0.0"
  vpc_id          = aws_vpc.vpc.id
  security_groups = var.security_groups
}
resource "aws_eip" "eip" {
  for_each = var.ec2
  instance     = aws_instance.server[each.key].id
  domain       = "vpc"
  # depends_on                = [aws_internet_gateway.gw]
}
output "my_eip" {
  value = {for k, v in aws_eip.eip : k => v.public_ip}
}

# resource "aws_security_group" "default" {
#   for_each = var.security_groups

#   name        = each.key
#   description = each.value.description
#   vpc_id      = aws_vpc.main.id

#   dynamic "ingress" {
#     for_each = each.value.ingress_rules != null ? each.value.ingress_rules : []

#     content {
#       description = ingress.value.description
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#     }
#   }

#   dynamic "egress" {
#     for_each = each.value.egress_rules != null ? each.value.egress_rules : []


#     content {
#       description = egress.value.description
#       from_port   = egress.value.from_port
#       to_port     = egress.value.to_port
#       protocol    = egress.value.protocol
#       cidr_blocks = egress.value.cidr_blocks
#     }
#   }
# }

resource "aws_instance" "server" {

  for_each = var.ec2
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mini_project.key_name

  subnet_id     = aws_subnet.subnet[each.key].id
  #vpc_security_group_ids = [module.security_groups.security_group_id["cloud_2023_sg"]] 
  vpc_security_group_ids = [module.security-groups.security_group_id["Mini_project_sg"]]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd.service
              sudo systemctl enable httpd.service
              sudo echo "<h1> HELLO from ${each.value.server_name} </h1>" > /var/www/html/index.html                  
              EOF
  tags = {
    Name = join ("_", [var.prefix, each.key])
  }
}
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
 
#   tags = {
#     Name = "${var.prefix}-vpc"
#   }
# }

resource "aws_subnet" "subnet" {
  vpc_id   = aws_vpc.vpc.id
  for_each = var.subnets
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = true # To ensure the instance gets a public IP
 
  tags = {
    Name = each.value.name
  }
}
# import {  
#   to = aws_instance.cloud_2023
#   id = "i-0ff84785c4dad6310"
#   }
