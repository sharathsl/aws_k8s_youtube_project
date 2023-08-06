resource "aws_instance" "public_instance" {
    instance_type = "t2.micro"
    ami = "ami-089ffe32605122764"
    key_name = "create_vpc_instance"
    subnet_id = aws_subnet.public_subnet[0].id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.dev-sg-public.id]

    tags = {
      Name = "${var.environment}-public"
      Environment = "${var.environment}"
    }
}

resource "aws_instance" "private_instance" { 
    instance_type = "t2.micro"
    ami = "ami-089ffe32605122764"
    key_name = "create_vpc_instance"
    subnet_id = aws_subnet.private_subnet[0].id
    vpc_security_group_ids = [aws_security_group.dev-sg-private.id]

    tags = {
      Name = "${var.environment}-private"
      Environment = "${var.environment}"
    }  
}
