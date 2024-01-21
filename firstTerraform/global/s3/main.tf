#s3 bucket

resource "aws_s3_bucket" "terraform_state" {
  #name must be globally unique
  bucket = "terraform-up-and-running-state-remote-backend"

  # to prevent accidental deletion of this s3 bucket
  lifecycle {
    prevent_destroy = true
  }
}