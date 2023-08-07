resource "aws_instance" "ec2-public" {
    ami = "ami-089ffe32605122764"
    instance_type = "t2.medium"
    associate_public_ip_address = true
    key_name = "create_vpc_instance"
    
    root_block_device {
      volume_size = "20"
      volume_type = "gp2"
      delete_on_termination = true
    }
    
    tags = {
      Name = "Jenkins-master"
      Environment = "Dev"
    }
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("C:/Users/shara/Downloads/create_vpc_instance.pem")}"
      host = aws_instance.ec2-public.public_ip
    }

    provisioner "file" {
        source = "C:/Users/shara/OneDrive/Desktop/AWS K8s Youtube  Project/create_ec2_install_jenkins_maven/install.sh"
        destination = "/tmp/install.sh"
    }

    provisioner "remote-exec" {
        inline = [ 
            "chmod 755 /tmp/install.sh"
         ]    
    }
}

