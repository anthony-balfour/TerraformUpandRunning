# Web server cluster variables. Includes server port number which defaults at 8080

variable "server_port" {
  description = "The port the server will use for http requests"
  type = number
  default = 8080
}