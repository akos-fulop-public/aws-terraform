data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "demo_app_security_group" {
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "demo_app_target_group" {
  name = "demo-app-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnets" "default_subnets" {
}

resource "aws_lb" "demo_app_load_balancer" {
  name               = "demo-app-target-group"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demo_app_security_group.id]
  subnets            = data.aws_subnets.default_subnets.ids
}

resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.demo_app_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo_app_target_group.arn
  }
}

output "app_url" {
  value = aws_lb.demo_app_load_balancer.dns_name
}

resource "aws_launch_template" "demo_app_launch_template" {
  name_prefix   = "demo_template"
  image_id      = "ami-0f845a2bba44d24b2"
  instance_type = "t2.micro"
  user_data = filebase64("${path.module}/launchscript.sh")
  vpc_security_group_ids = [ aws_security_group.demo_app_security_group.id]
}

resource "aws_autoscaling_group" "demo_app_autoscaling_group" {
  name                      = "demo_app_autoscaling_group"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 10
  vpc_zone_identifier = data.aws_subnets.default_subnets.ids
  launch_template {
    id = aws_launch_template.demo_app_launch_template.id
  }
}

resource "aws_autoscaling_attachment" "demo_lb_autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.demo_app_autoscaling_group.id
  lb_target_group_arn = aws_lb_target_group.demo_app_target_group.arn
}
