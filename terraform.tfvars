# variable "servers" {
#   type = map(object({
#     name                = string
#     cidr_block          = string
#     availability_zone   = string
#   }))
 
#   default = {
#     app = {
#       name = "APP",
#       cidr_block = ["10.0.1.0/24"]
#       availability_zone = "us-eat-1a"
#     },
#     dev = {
#       name = "DEV",
#       cidr_block = ["10.0.2.0/24"]
#       availability_zone = "us-eat-1b"
#     },
#     web = {
#       name = "WEB",
#       cidr_block = ["10.0.3.0/24"]
#       availability_zone = "us-eat-1c"
#     }
#   }
# }
security_groups = {
  "Mini_project_sg" : {
    description = "Security group for web servers"
    ingress_rules = [
      {
        description = "ingress rule for http"
        priority    = 200
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "my_ssh"
        priority    = 202
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "ingress rule for http"
        priority    = 204
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}
# variable "ec2" {
#   type = map(object({
#     name = string,
#     # cidr_block = string
#     # availability_zone = string
#   }))
#   default = {
#     app = {
#         server_name = "APP"
#     }
#     dev = {
#         server_name = "DEV"
#     }
#     web = {
#         server_name = "WEB"
#   }
#  }
# }
