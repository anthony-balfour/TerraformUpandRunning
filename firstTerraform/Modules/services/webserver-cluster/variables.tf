variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 buckt for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type = string
}

// use case of wanting smaller server cluster in staging but larger in production
variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type = number
}



// Server port number which defaults to 8080
variable "server_port" {
  description = "The port the server will use for http requests"
  type = number
  default = 8080
}



