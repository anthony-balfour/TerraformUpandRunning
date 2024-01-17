####### Modularize
# Cluster of servers

#on AWS use Auto Scaling Group
# Manages cluster of ec2 instances, monitors health, auto replaces, adjusting size of cluster

#first step is to create a launch configuration which specifies how to configure each EC2 instance
# within the auto scaling group
# aws launch config resource uses

resource "aws_launch_configuration" "cluster" {
  image_id = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  # Required when using a launch configuration with an auto scaling group
  # every resource supports several lifecycle settings that configure how that resource is
# is created updated or deleted, normally resources are deleted first, then created
# however, we want this configuration to be created first so that the cluster will be updated properly with the new configuration
# if not, terraform wont delete the old configuration because the asg references it. configurations are immutable.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.cluster.name
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

# Accessing the Database state file which stores the secrets of db username and password
# Reads the state file from the s3 bucket and folder, and is READ-ONLY
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "(YOUR_BUCKET_NAME)"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
  }
}

### Ways to read data from the terraform remote state data source

// data.terraform_remote_state.<NAME>.outputs.<ATRRIBUTE>

// example:
// data.terraform_remote_state.db.outputs.address


### Terraform console - read only console which can be used to experiment with terraform functions

// function_name(...)
// format(<FMT>, <ARGS>, ...)
//format ("%.3f", 3.1459)

####### Modularize

# S3 backend configuration
terraform {
  // name of bucket created
  // key: the filepath withint he s3 bucket where the terraform statefile should be written
  // same region specified
  // dynamodb table craeted
  // encyrption
  backend "s3" {
    bucket = "terraform-up-and-running-state-remote-backend"
    key = "stage/services/webserver-cluser/terraform.tfstate"
    region = "us-east-2"

    # Dynamo DB table name
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}

# Moducles

module "webserver_cluster" {
  source ="../../../Modules/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "(BUCKET NAME)"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
}

### prod module

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name ="webservers-prod"
  db_remote_state_bucket = "(BUCKET NAME)"
  db_remote_state_key =  "prod/data-stores/mysql/terraform.tfstate"
}