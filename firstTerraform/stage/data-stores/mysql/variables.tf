// environment variables for username and password
// secrets for the MySQL hosted on RDS

variable "db_username" {
  description = "The username for the database"
  type = string
  sensitive = true // denotes that it contains secrets, meaning they wont be logged on terraform plan or apply
}

variable "db_password" {
  description = "The password for the database"
  type = string
  sensitive = true
}