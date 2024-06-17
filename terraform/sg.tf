resource "aws_security_group" "web_server_lb" {
  name        = "web-server-LB-sg"
  description = "Allow HTTP access from the world"
  vpc_id      = module.vpc.vpc_id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_security_group" "internal" {
  name        = "web-server-internal"
  description = "Allow traffic between ALB and servers"
  vpc_id      = module.vpc.vpc_id


  ingress {
    from_port   = 80
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.web_server_lb.id]
  }

  ingress {
    from_port   = 80
    to_port     = 3010
    protocol    = "tcp"
    security_groups = [aws_security_group.web_server_lb.id]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_security_group" "web_servers" {
  name        = "web-server-sg"
  description = "Allow SSH access and HTTP access for health checks"
  vpc_id      = module.vpc.vpc_id


  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for health checks"
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
