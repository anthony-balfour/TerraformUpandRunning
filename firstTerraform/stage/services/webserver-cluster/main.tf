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