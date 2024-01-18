
// security group named alb
// takes in var.cluster_name variable from module
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"

  ingress {
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

//launch configuration for web server cluster
// takes in var.cluster_name variable

resource "aws_launch_configuration" example {
  image_id = "ami-0fb653ca2d3203ac1"
  instance_type = var.instance_type
  security_groups = [aws_security_group.instance.id]

  user_data = templatefile("user-data.sh", {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  })

  # Required lifecycle when using a launch config with an ASG
  lifecycle {
    create_before_destroy = true
  }
 }

 // auto scaling group
 resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids


  # target groups are servers that receives requests from the load balancer, target group performs health checks on the servers
  # and only sends to healthy nodes
  target_group_arns = [aws_lb_target_group.asg.arn]

  # replaces down instances with new ones if down or ran out of memory
  health_check_type = "ELB"

  # specifying size of server clusters, initial size is 2
  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}



