#s3 bucket
#name must be globally unique
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-remote-backend"

  # to prevent accidental deletion of this s3 bucket
  lifecycle {
    prevent_destroy = true
  }
}