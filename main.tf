#---------------#
#    Keypair    #		
#---------------#

resource "aws_key_pair" "auth_key" {
  key_name = "${var.project_name}-${var.project_env}"
  public_key = file("mykey.pub")
  tags = {
    Name = "${var.project_name}-${var.project_env}"
	Project = var.project_name
    Env = var.project_env
  }
}

#-----------------#
# Security Groups #
#-----------------#

resource "aws_security_group" "access" {
  name        = "${var.project_name}-${var.project_env}-access"
  description = "${var.project_name}-${var.project_env}-access"
  
    ingress {
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-access"
    Project = var.project_name
    Env = var.project_env
  }
}

#-------------#-#
# EC2 Instance #
#--------------#

resource "aws_instance" "frontend" {
  #ami = data.aws_ami.latest.id
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.auth_key.id
  vpc_security_group_ids = [aws_security_group.access.id]
  tags = {
    Name = "${var.project_name}-${var.project_env}-frontend"
    Project = var.project_name
    Env = var.project_env
	
  }
  lifecycle {
    create_before_destroy = true
  }
}

#-------------#
# DNS Records #
#-------------#

resource "aws_route53_record" "frontend-record" {
  zone_id = data.aws_route53_zone.public.id
  name    = "${var.hostname}.${var.hosted-zone-name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.frontend.public_ip]
}
