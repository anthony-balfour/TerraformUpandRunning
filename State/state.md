 Every time Terraform is run, it records ifnormation about hte infrastructure in a Terraform state
  the files contains a custom JSON formation which maps Terraform resources to those resources
  in the real world

# resource "aws_instance" "example" {
#   ami = "ami-0fb653ca2d3203ac1"
#   instance_type = "t2.micro"
# }

 checks real world status vs configuration and determines the difference with ID's
 - version control does not account for locking, private information (plain text state information), and consistent
    state file/current state synchronization
    terraform backend handles this

# Terraform backend determines how state is stored and managed and loaded
 - can store on remote backends or local backends
 - backends automatically are stored on every apply and plan

# Benefits to backend
-locking
-encryption
-s3 is a great remote backend, can configure access control with iam policies
 managed, so no extra infrastructure
 designed for 99% durability and availability
 supports encryption
 supports locking
 versioning
 inexpensive

