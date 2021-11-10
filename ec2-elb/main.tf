provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "default" {
  name = "deep-security-DSM"

  ingress {
    from_port = 4120
    to_port = 4120
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "default" {
  key_name = "trend-deep"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "deep-security-manager-1" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.default.id}"
  security_groups = ["${aws_security_group.default.name}"]
  user_data = "${file("bootstrap1.sh")}"

  tags {
    Name = "deep-security-manager-1"
  }
}

resource "aws_instance" "deep-security-manager-2" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.default.id}"
  security_groups = ["${aws_security_group.default.name}"]
  user_data = "${file("bootstrap2.sh")}"

  tags {
    Name = "deep-security-manager-2"
  }
}

resource "aws_elb" "default" {
  name = "ec2-elb"
  instances = ["${aws_instance.server1.id}", "${aws_instance.server2.id}"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  health_check {
    target = "HTTP:80/"
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 30
    timeout = 5
  }

  tags {
    Name = "ec2-elb"
  }
}
