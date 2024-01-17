# Servers
Typically will have 2 envrionments, one for staging, and one for prod, both pretty identical.
Though probably less servers in staging group
Environments will have (ELB -> ASG -> MySQL)

# Module
- similar to a funciton, where reusable blocks of code can be used
- Entire infrastructure is a collection of reusable modules
- reusable, maintaable, scalable, and testable Terraform code

# Module definition
  - any set of Terraform configuration files in a folder is a module
  - applying a module makes it a root module
  - reusable module is meant to be reused within other modules

  # Syntax

  module <Name> {
    source = "<Source>" source is the path of the module

    [CONFIG...] arguments specific to the module
  }

  for example

provider "aws" {
  region = "us-east-2"
}
  module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"
  }

# Init command
- must run anytime source is modified or adding a new module

# Input variables

