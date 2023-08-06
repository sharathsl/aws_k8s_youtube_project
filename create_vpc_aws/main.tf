locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}

resource "aws_vpc" "vpc" { 
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.environment}-vpc"
        Environment = var.environment
    }     
}

resource "aws_security_group" "dev-sg-public" {
    vpc_id = aws_vpc.vpc.id

    tags = {
       Name = "${var.environment}-public-sg"
       Environment = var.environment
    }
    ingress  {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = [ "0.0.0.0/0" ]
    }    
}

resource "aws_security_group" "dev-sg-private" { 
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "${var.environment}-private-sg"
      Environment = var.environment
    }
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["10.0.0.0/20"]
    } 
    egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = [ "0.0.0.0/0" ]
    }   
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc.id
    count = length(var.public_subnet_cidr)
    cidr_block = element(var.public_subnet_cidr,count.index)
    map_public_ip_on_launch = true
    availability_zone = element(local.availability_zones, count.index)

    tags = {
      Name = "${var.environment}-public-subnet"
      Environment = var.environment
    } 
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.vpc.id
    count = length(var.private_subnet_cidr)
    cidr_block = element(var.private_subnet_cidr,count.index)
    map_public_ip_on_launch = false
    availability_zone = element(local.availability_zones, count.index)

    tags = {
      Name = "${var.environment}-private-subnet"
      Environment = var.environment
    }
}

resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "${var.environment}-igw"
      Environment = var.environment
    }
}

resource "aws_eip" "nat_eip" {
    domain = "vpc"
    depends_on = [ aws_internet_gateway.ig ]  
}

resource "aws_nat_gateway" "nat" {
    allocation_id  = aws_eip.nat_eip.id
    subnet_id = element(aws_subnet.public_subnet.*.id,0)
    
    tags = {
      Name = "nat-gateway-${var.environment}"
      Environment = "${var.environment}"
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "${var.environment}-private-route-table"
      Environment = "${var.environment}"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "${var.environment}-public-route-table"
      Environment = "${var.environment}"
    }
}

resource "aws_route" "public_ig" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
}

resource "aws_route" "private_ig" {
    route_table_id         = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_nat_gateway.nat.id  
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}