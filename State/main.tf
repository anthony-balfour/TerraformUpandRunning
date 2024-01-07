provider "aws" {
  region = "us-east-2"
}

#s3 bucket
#name must be globally unique
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-remote-backend"

  # to prevent accidental deletion of this s3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# enables bucket versioning
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

// turn on server side encryption for all data written to this s3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}

# block all public access to the s3 bucket
# which are easy to make public since they are often used to serve static content such as js html
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

// create DynamoDB table to use for locking. Dynamo is Amaazon's dstributed key-value store
// strongly consistent reads and conditional writes.
// its completely managed, so no extra infrastructure needed
// distributed means distributed across multiple servers
// data is typically stored in key value pairs, and supports frequent requests with low latency

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# after running init and apply here, terraform still will still be stored locally until I
// add a backend configuration to my code.

// terraform configuration has this syntax:
# terraform {
#   backend "name" {
#     [CONFIG...]
#   }
# }


#run terraform init, which will change backend from local to s3

### Order of creating remote backend ###
# order is create s3 bucket and dynamodb with local backend
// then transfer it to remote backend running init again



### Deleting remote backend ###
# to delete: remove the terraform backend config, run terraform init to localize state

# then run terraform destroy to delete the s3 bucket and dynamodb table
# cannot use variables or references in terraform backend configuration
# terraform modules are a way to organize and reuse terraform code and most real-world
# application uses many small modules
# need unique key for every terraform module

# to not have to copy paste all the congif can create a -backend-config file rn
# when i run terraform init, into a file called backend.hcl

#terraform init -backend-config = backend.hcl
#terragrunt can help with this by setting all the basic backend settings, and automatically
# setting the key argument

### Terraform backend code initial example ###
terraform {
  // name of bucket created
  // key: the filepath withint he s3 bucket where the terraform statefile should be written
  // same region specified
  // dynamodb table craeted
  // encyrption
  backend "s3" {
    bucket = "terraform-up-and-running-state-remote-backend"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"

    # Dynamo DB table name
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}

# creating output variables to demonstrate state versioning and locking
# arn is amazon resource name - with unique identifier account id: service: resource-id
output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the s3 bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}

### Reducing Copy paste of different backend configurations ###

# -use partial configurations
#   -omit parameters from configuration
#   -pass those omitted values in via =backend=config cli argumnents when calling terraform init
#   -Example of repeated values in backend.hcl file

  /* backend.hcl
     bucket = "terraform-up-and-running-state"
     region = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  */

  /*
    # Partial configuration. The other settings (e.g., bucket,
    region) will be passed in from a file via -backend-config arguments to
    'terraform init'

    terraform {
      backend "s3" {
      key = "example/terraform.tfstate"
      }
    }

    To put all your partial configurations together, run terraform init
    with the -backend-config argument:

    $ terraform init -backend-config=backend.hcl
  */


### Workspaces###

/*

Workspaces isolate state files and are literally different workspaces
Command:

terraform workspace new example1

or

terraform workspace new example2

or

terraform workspace show - shows current workspace

or

terraform workspace list

or

terraform workspace select - to pick a different workrspace

Inside each workspace Terraform uses the key I specified in my backend configuration
and creates a new path and thus new workspace or state

Effective for updating or experimenting with code

*/


### Ternary Code for different instance types based on workspace ###

resource "aws_instance" "example" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
}

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-remote-backend"
    key = "workspaces-example/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}


### Workspaces ###

/*
  - all workspaces are in same s3 bucket which use same access controls so not suitable
    for isolating environments
  - Workspaces do not show up in code or in the cli, only by using workspaces command
  - maintenance issue
  - not suitable for isolation
  -suitable for quick testing of same config
*/

