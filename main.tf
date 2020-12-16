provider "aws"{
    region = "us-east-1"
    access_key = 
    secret_key =
}

#SECURITYGROUP
#SECURITYGROUP
#SECURITYGROUP

resource "aws_security_group" "Sg-Lab6" {
    name = "Sg-Lab6"
    vpc_id = "vpc-9431ece9"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Sg-Lab6"
  }
}

#LOADBALANCER
#LOADBALANCER
#LOADBALANCER

resource "aws_lb" "ElbLab6" {
  name = "ElbLab6"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.Sg-Lab6.id ]
  subnets = [ "subnet-b90858f4", "subnet-bd2852b3" ]

  tags = {
    Name = "ElbLab6"
  }
}

resource "aws_lb_target_group" "TgElb" {
  name     = "Lab6-Target-Group"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id = "vpc-9431ece9"
}

resource "aws_lb_target_group_attachment" "TgAttach" {
  target_group_arn = aws_lb_target_group.TgElb.arn
  count = length(aws_instance.webServer)
  target_id = aws_instance.webServer[count.index].id
  port = 80
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.ElbLab6.arn
    port = 80
    protocol = "HTTP"

  default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.TgElb.arn
    }
  }

#INSTANCES
#INSTANCES
#INSTANCES

resource "aws_instance" "webServer" {
  count = 2
  ami = "ami-095e76321bd6305ab"
  instance_type =  "t2.micro"
  key_name = "DmytroKey3"
  disable_api_termination = true
  security_groups = [ aws_security_group.Sg-Lab6.name ]

  user_data = file("apache1.sh")

  tags = {
     Name = format("lab6-i-%d", count.index)
   }

}
