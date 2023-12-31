# First step is to configure the provider im going to use

provider "aws" {
  region = "us-east-2"
}

# Terraform/firstTerraform/.terraform/providers/registry.terraform.io/hashicorp/aws/5.26.0/windows_amd64/terraform-provider-aws_v5.26.0_x5.exe
# a single virtual server in AWS known as EC2 instance

# resource "<PROVIDER>_<TYPE>" "<NAME>" {
#   [CONFIG...]
# }

# general syntax for creating a resource in Terraform is:
# resources include servers, databases, load balancers
# name is variable name of the resource, it's identifier
# type is the type of resource
# config is arguments specific to that resource

# aws_instance requires two arguments:
# ami
# instance_type - t2.micro is part of free tier
# resource "aws_instance" "firstServer" {
#   ami = "ami-0fb653ca2d3203ac1"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.instance.id]

#   user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello, World" > index.html
#                 nohup busybox httpd -f -p ${var.server_port} &
#                 EOF

#   tags = {
#     Name = "terraform-firstServer"
#   }

#   #EOF allows multi line strings

#   # recreates the instance on user data change
#   # since user data runs on boot, this hello world will run
#   # because user data only runs on first boot, so the instance must be recreated
    # because hello world will only run on boot
#   user_data_replace_on_change = true
# }


# After runnning terraform init, provider info is donwloaded into terraform.lock.hcl file, need to run init anytime you start with new terraform code
# plan command is what the configuration is before sending to code, review check
# then run terraform apply

# must create security allowance because by default aws does not allow inbound or outgoing traffic
# to EC2, to reference this resource, can use an expression that uses the id
# value exported by this resource [aws_security_group.instance.id]

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#terraform graph shows dependency graph of resources, such as aws instance on security group, which depend on eachother
# this can turn into an image, a literal image, using Graphvizcurl

output "alb_dns_name" {
  # value = aws_instance.firstServer.public_ip
  # public ip is the DNS name of the load balancer which routes traffic
 #  description = "The public IP address of the web server"

 # grabbing dns name from aws_lb - load balancer
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

# Other parameter for ASG is subnet_ids, which is needed to specifiy which subnets
#should the ec2 instances be deployed to. Subnet ids are grabbed as a datasource from
#AWS as read-only data, which is grabbed every time Terraform is run
#Data sources incllude vpc data, subnet data, ami IDS, IP address ranges, current
# user identity,

# format is data provider_type name
  # config ...

#Default VPC data
#data source is a piece of read only info that is fecthed from the provider everytime you run terraform. it queries the apis for data and makes that data vailable
#aws can look up vpc data, sbunet data, ami  IDS, IP address ranges,

#looks up default cpv
data "aws_vpc" "default" {
  default = true
}


# can grab the subnet ids and place into autoscaling group
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


#Load Balancer - can give IP address/DNS name of load balancer to client
# aws has elastic load balancer
# two main types: application load balancer for https traffic
# network load balancer for tcp traffic, high scalability
# aws laod balancers run in isolated databases

resource "aws_lb" "example" {
  name = "terraform-asg-example"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

# need a listener for this load balancer

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"

  #return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "terraform-example-alb"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# allows all outbound requests for health checks on the alb
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# next up is target group

resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  # periodically sends health check to instances
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

# listener rules that sends request tha match any path to the target group
# that contains my asg
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}


