#terrform key pair 
resource "aws_key_pair" "deployer" {
  key_name   = "terra-key"
  public_key = file("terra-key.pub")
}

#default vpc
resource "aws_default_vpc" "default" {

}

#security group to allow user to connect
resource "aws_security_group" "allow_user_to_connect" {
  name        = "allow TLS"
  description = "Allow user to connect"
  vpc_id      = aws_default_vpc.default.id


  #inbound rule port 22
  ingress {
    description = "port 22 allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #outbound rule
  egress {
    description = " allow all outgoing traffic "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #inbound rule port 80 and 443
  ingress {
    description = "port 80 allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 443 allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_wanderlust"
  }
}

#ec2 instance 

resource "aws_instance" "wanderlust_instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_user_to_connect.name]
  tags = {
    Name = "wanderlust_instance"
  }
  root_block_device {
    volume_size = 30 
    volume_type = "gp3"
  }
}


#output public ip
output "instance_public_ip" {
  value = aws_instance.wanderlust_instance.public_ip
}     

output "instance_security_group" {
  value = aws_instance.wanderlust_instance.security_groups
  
}

output "key_name" {
  value = aws_key_pair.deployer.key_name    
  
}