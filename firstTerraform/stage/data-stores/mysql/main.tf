# RDS Setup for MySQL service

provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"

  engine = "mysql" // database engine, which powers database functionality
  allocated_storage = 10 //GB
  instance_class = "db.t2.micro" //Free tier, one virtual cpu, 1gb of memory
  skip_final_snapshot = true //destroy will fail if the final snapshot isnt disabed or identified
  db_name = "example_database"

  // one option to store secrets safely outside of terraform and pass those secrets
  // into Terraform using environment variables
  // (in the variables file)
  username = var.db_username //Secrets so not directly into code in plain text, imported from variables file
  password = var.db_password
}

# configuring module to store its state in the s3 bucket created for my files

terraform {
  backend "s3" {
    bucket = ""
    key = "stage/data-stores/mysql/terraform.tfstate"
    region= "use-east-2"


  dynamodb_table = ""
  encrypt = true
  }
}