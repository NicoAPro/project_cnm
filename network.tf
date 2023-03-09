resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${terraform.workspace}-vpc"
    Environment = terraform.workspace
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.sub_public_cidr

  tags = {
    Name = "${terraform.workspace}-public"
    Environment = terraform.workspace
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.sub_private_cidr

  tags = {
    Name = "${terraform.workspace}-private"
    Environment = terraform.workspace
  }
}

resource "aws_network_acl" "acl_public" {
    vpc_id = aws_vpc.main_vpc.id
    subnet_ids = [aws_subnet.public_subnet.id]
    egress {
        protocol = "-1"
        rule_no = 1
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
        protocol = "tcp"
        rule_no = 4
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 22
        to_port = 22
    }
    ingress {
        protocol = "tcp"
        rule_no = 5
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }
    ingress {
        protocol = "tcp"
        rule_no = 6
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }
    ingress {
        protocol = "tcp"
        rule_no = 7
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 1024 #32768
        to_port = 65535
    }
    ingress {
        protocol = "udp"
        rule_no = 9
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 1024 #32768
        to_port = 65535
    }
    ingress {
        rule_no = 10
        protocol = "icmp"
        icmp_type = -1
        icmp_code = -1
        from_port = 0
        to_port = 0
        cidr_block = aws_subnet.public_subnet.cidr_block
        action = "allow"
    }
    ingress {
        protocol = "-1"
        rule_no = 16
        action = "allow"
        cidr_block = aws_subnet.public_subnet.cidr_block
        from_port = 0
        to_port = 0
    }
    tags = {
        Name = "${terraform.workspace} public network acl"
        Environment = terraform.workspace
    }
}

resource "aws_network_acl" "acl_private" {
    vpc_id = aws_vpc.main_vpc.id
    subnet_ids = [aws_subnet.private_subnet.id]
    egress {
        protocol = "-1"
        rule_no = 1
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
        protocol = "tcp"
        rule_no = 2
        action = "allow"
        cidr_block = aws_subnet.public_subnet.cidr_block
        from_port = 22
        to_port = 22
    }
    ingress {
        protocol = "tcp"
        rule_no = 3
        action = "allow"
        cidr_block = aws_subnet.public_subnet.cidr_block
        from_port = 3306
        to_port = 3306
    }
    tags = {
        Name = "${terraform.workspace} private network acl"
        Environment = terraform.workspace
    }
}

# create internet gateway
resource "aws_internet_gateway_attachment" "internet_gateway" {
  internet_gateway_id = aws_internet_gateway.internet_gateway.id
  vpc_id              = aws_vpc.main_vpc.id
}

resource "aws_internet_gateway" "internet_gateway" {
    tags = {
        Name = "${terraform.workspace} internet gw terraform generated"
        Environment = terraform.workspace
    }
}

# création de la route de sortie
resource "aws_route_table" "internet" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    tags = {
        Name = "${terraform.workspace} route table"
        Environment = terraform.workspace
    }
}

# association de la route de sortie au subnet public
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.internet.id
}