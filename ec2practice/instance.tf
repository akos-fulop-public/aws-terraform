resource "aws_instance" "app_server" {
  ami           = "ami-0f845a2bba44d24b2"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }

  key_name               = "akos-notebook"
  vpc_security_group_ids = [aws_security_group.ssh_inbound.id,aws_security_group.http_inbound.id,aws_security_group.internet.id]

  user_data = <<EOF
#!/bin/bash
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
  EOF
}

output "instance_url" {
  value = aws_instance.app_server.public_dns
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "ssh_inbound" {
  name = "allow_ssh"
  description = "Allow SSH"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "http_inbound" {
  name = "allow_http"
  description = "Allow HTTP"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internet" {
  name = "allow_internet"
  description = "Allow internet"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "test_target_group" {
  name = "website-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test_target_group.arn
  target_id        = aws_instance.app_server.id
  port             = 80
}

data "aws_subnets" "default_subnets" {
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_inbound.id,aws_security_group.internet.id]
  subnets            = data.aws_subnets.default_subnets.ids
}
