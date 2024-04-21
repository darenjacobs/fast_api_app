provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-pb0004888"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_instance" "app_server" {
  ami           = var.server_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups = [aws_security_group.allow_web.name]

  # User data to install Docker and run container - consider using Ansible for more complex setups
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo docker run -d -p 80:80 darenjacobs/fastapi-app:latest
              EOF

  tags = {
    Name = "FastAPIAppServer"
  }
}
