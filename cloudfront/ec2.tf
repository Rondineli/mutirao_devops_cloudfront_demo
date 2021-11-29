resource "aws_security_group" "allow_http_traffic" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Http for the app"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_flask_app_http"
  }
}

resource "aws_security_group" "allow_to_ec2" {
  name        = "allow_ssh_ec2_instance"
  description = "Allow ssh inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "SSH for the ec2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  ingress {
    description     = "HTTP for the ec2 from elb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_http_traffic.id]
    self            = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_flask_ec2_ssh"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/files/userdata.tpl")

  vars = {
    bucket_and_key_object = "http://${aws_s3_bucket.public-code-bucket.id}/app/app.zip"
  }
}

resource "aws_launch_configuration" "lc-app-nodes" {
  associate_public_ip_address = true
  image_id                    = data.aws_ami.ec2.id
  instance_type               = var.instance_type
  name_prefix                 = "flask-example-app"
  security_groups             = [aws_security_group.allow_to_ec2.id]
  user_data                   = data.template_file.user_data.rendered
  key_name                    = var.ssh_key

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "all_apps" {
  depends_on           = [aws_elb.elb]
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.lc-app-nodes.id
  health_check_type    = "ELB"
  max_size             = 3
  min_size             = 1
  name                 = "flask-example-app"
  vpc_zone_identifier  = local.subnet_ids_list
  load_balancers       = [aws_elb.elb.name]

  tag {
    key                 = "Name"
    value               = "flask-example-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "autopolicy" {
  name                   = "terraform-autoplicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.all_apps.name
}

resource "aws_elb" "elb" {
  name            = "terraform-elb"
  security_groups = [aws_security_group.allow_http_traffic.id]
  subnets         = local.subnet_ids_list

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "flask-app-elb"
  }
}

resource "aws_lb_cookie_stickiness_policy" "cookie_stickness" {
  name                     = "cookiestickness"
  load_balancer            = aws_elb.elb.id
  lb_port                  = 80
  cookie_expiration_period = 600
}
