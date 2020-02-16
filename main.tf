provider "aws" {
	region  = "eu-central-1"
 }


resource "aws_launch_configuration" "example" {
	image_id	      = "ami-0b418580298265d5c"
	instance_type 	      = "t2.micro"
	security_groups	      = [aws_security_group.instance.id]

	user_data = <<-EOF
		 #!/bin/bash
		 echo "Hello, This is a simple Web Server" > index.html
		 nohup busybox httpd -f -p ${var.server_port} &
		 EOF

	lifecycle {
		 create_before_destroy = true
  } 
 }

variable "server_port" {
	description = "The port the server will use for HTTP requests"
	type	    = number
	default	    = 8080
 }

resource "aws_security_group" "instance" {
	name = terraform-example-instance"

	ingress {
	 from_port   = var.server_port
	 to_port     = var.server_port
	 protocol    = "tcp"
	 cidr_blocks = ["0.0.0.0/0"]
  }
 }

resource "aws_autoscaling_group" "example" {
	launch_configuration = aws_launch_configuration.example.name
	vpc_zone_identifier  = data.aws_subnet_ids.default.ids
	min_size = 2
	max_size = 10

	tag {
	 key                 = "Name"
	 value		     = "terraform-asg-example"
	 propagate_at_launch = true
  }
 }

data "aws_vpc" "default" {
	default = true

data "aws_subnet_ids" "default" {
	vpc_id = data.aws_vpc.default.idi
