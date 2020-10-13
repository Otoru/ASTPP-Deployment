resource "aws_default_vpc" "default" {
  tags = {
    system      = "astpp"
    service     = "network"
  }
}

resource "aws_key_pair" "workstation" {
  key_name   = "workstation"
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    system      = "astpp"
    environment = "prd"
    service     = "ssh"
  }
}

resource "aws_security_group" "outbound" {
  name        = "outbound"
  description = "Allow outbound traffic"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    system      = "astpp"
    service     = "ssh"
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  tags = {
    system      = "astpp"
    service     = "ssh"
  }
}

resource "aws_security_group" "sip" {
  name        = "sip"
  description = "Allow SIP inbound traffic"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 5060
    to_port   = 5060
    protocol  = "udp"
  }

  tags = {
    system      = "astpp"
    service     = "sip"
  }
}

resource "aws_security_group" "rtp" {
  name        = "rtp"
  description = "Allow RTP inbound traffic"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 16384
    to_port   = 32767
    protocol  = "udp"
  }

  tags = {
    system      = "astpp"
    service     = "sip"
  }
}

resource "aws_security_group" "http" {
  name        = "http/s"
  description = "Allow HTTP/S inbound traffic"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }

  tags = {
    system      = "astpp"
    service     = "https"
  }
}

resource "aws_instance" "astpp" {
  associate_public_ip_address = true
  ami                         = "ami-0947d2ba12ee1ff75"
  key_name                    = aws_key_pair.workstation.key_name
  instance_type               = "t2.micro"

  security_groups = [
    aws_security_group.outbound.name,
    aws_security_group.http.name,
    aws_security_group.ssh.name,
    aws_security_group.sip.name,
    aws_security_group.rtp.name,
  ]

  tags = {
    system      = "astpp"
  }
}

resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "Allow MySQL inbound traffic from my machine"

  ingress {
    cidr_blocks = [
      aws_default_vpc.default.cidr_block
    ]
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
  }

  tags = {
    system      = "astpp"
    service     = "database"
  }
}

resource "aws_db_parameter_group" "astpp" {
  family = "mysql8.0"

  parameter {
    name          = "log_bin_trust_function_creators"
    value         = 1
    apply_method  = "pending-reboot"
  }

parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8"
  }

  parameter {
    name  = "collation_server"
    value = "utf8_general_ci"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8_general_ci"
  }

  parameter {
    name  = "max_connect_errors"
    value = "1000"
  }

  parameter {
    name  = "max_connections"
    value = "10000"
  }

  tags = {
    system      = "astpp"
    service     = "database"
  }
}

resource "aws_db_instance" "astpp" {
  identifier               = "astpp"
  allocated_storage        = 16
  backup_retention_period  = 7
  engine                   = "mysql"
  engine_version           = "8.0"
  instance_class           = "db.t2.micro"
  name                     = "astpp"
  username                 = "astpp"
  password                 = var.database_password
  port                     = "3306"
  publicly_accessible      = false
  skip_final_snapshot      = true

  parameter_group_name = aws_db_parameter_group.astpp.name

  vpc_security_group_ids   = [
    aws_security_group.mysql.id
  ]

  tags = {
    system      = "astpp"
    service     = "database"
  }
}

output "database" {
  value = aws_db_instance.astpp.address
}

output "web" {
  value = aws_instance.astpp.public_ip
}

output "dns" {
  value = aws_instance.astpp.public_dns
}

