# Project Phoenix - AWS Production Stack Simulation
# Terraform IaC for complete AWS infrastructure automation
# Author: Pravalika Dasika
# First Deployed: June 14, 2026

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Uncomment for remote state (AWS S3 backend)
  # backend "s3" {
  #   bucket         = "pravalika-terraform-state"
  #   key            = "project-phoenix/terraform.tfstate"
  #   region         = "ap-south-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Project-Phoenix"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = "Pravalika Dasika"
      CreatedDate = "2026-06-14"
    }
  }
}

# ============================================
# 1. VPC & NETWORKING
# ============================================

resource "aws_vpc" "phoenix_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "phoenix-vpc"
  }
}

resource "aws_internet_gateway" "phoenix_igw" {
  vpc_id = aws_vpc.phoenix_vpc.id

  tags = {
    Name = "phoenix-igw"
  }
}

resource "aws_subnet" "phoenix_public" {
  vpc_id                  = aws_vpc.phoenix_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "phoenix-public-subnet"
  }
}

resource "aws_subnet" "phoenix_private" {
  vpc_id            = aws_vpc.phoenix_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "phoenix-private-subnet"
  }
}

resource "aws_route_table" "phoenix_rt" {
  vpc_id = aws_vpc.phoenix_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.phoenix_igw.id
  }

  tags = {
    Name = "phoenix-rt"
  }
}

resource "aws_route_table_association" "phoenix_rt_assoc" {
  subnet_id      = aws_subnet.phoenix_public.id
  route_table_id = aws_route_table.phoenix_rt.id
}

# ============================================
# 2. SECURITY GROUPS
# ============================================

resource "aws_security_group" "phoenix_ec2_sg" {
  name        = "phoenix-ec2-sg"
  description = "Security group for Project Phoenix EC2 instances"
  vpc_id      = aws_vpc.phoenix_vpc.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  # TigerVNC access
  ingress {
    from_port   = 5901
    to_port     = 5901
    protocol    = "tcp"
    cidr_blocks = var.allowed_vnc_cidr
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress - Allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "phoenix-ec2-sg"
  }
}

resource "aws_security_group" "phoenix_rds_sg" {
  name        = "phoenix-rds-sg"
  description = "Security group for Project Phoenix RDS"
  vpc_id      = aws_vpc.phoenix_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.phoenix_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "phoenix-rds-sg"
  }
}

# ============================================
# 3. EC2 INSTANCES
# ============================================

resource "aws_key_pair" "phoenix_key" {
  key_name   = "phoenix-key"
  public_key = file(var.public_key_path)

  tags = {
    Name = "phoenix-key"
  }
}

resource "aws_instance" "phoenix_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.phoenix_key.key_name
  subnet_id              = aws_subnet.phoenix_public.id
  vpc_security_group_ids = [aws_security_group.phoenix_ec2_sg.id]
  associate_public_ip_address = true

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "phoenix-root-volume"
    }
  }

  # User data script to install Docker, XFCE, TigerVNC
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    vnc_password = var.vnc_password
  }))

  monitoring             = true
  ebs_optimized          = false

  tags = {
    Name = "phoenix-ec2"
  }

  depends_on = [aws_internet_gateway.phoenix_igw]
}

# Elastic IP for EC2
resource "aws_eip" "phoenix_eip" {
  instance = aws_instance.phoenix_ec2.id
  domain   = "vpc"

  tags = {
    Name = "phoenix-eip"
  }

  depends_on = [aws_internet_gateway.phoenix_igw]
}

# ============================================
# 4. RDS POSTGRESQL DATABASE
# ============================================

resource "aws_db_subnet_group" "phoenix_db_subnet" {
  name       = "phoenix-db-subnet-group"
  subnet_ids = [aws_subnet.phoenix_public.id, aws_subnet.phoenix_private.id]

  tags = {
    Name = "phoenix-db-subnet-group"
  }
}

resource "aws_db_instance" "phoenix_postgres" {
  identifier            = "phoenix-postgres-db"
  engine                = "postgres"
  engine_version        = "15.3"
  instance_class        = var.db_instance_type
  allocated_storage     = 20
  storage_type          = "gp3"
  storage_encrypted     = true
  
  db_name  = "phoenixdb"
  username = var.db_username
  password = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.phoenix_db_subnet.name
  vpc_security_group_ids = [aws_security_group.phoenix_rds_sg.id]
  
  publicly_accessible    = false
  skip_final_snapshot    = false
  final_snapshot_identifier = "phoenix-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  enable_cloudwatch_logs_exports = ["postgresql"]
  deletion_protection    = false
  
  tags = {
    Name = "phoenix-postgres-db"
  }
}

# ============================================
# 5. S3 BUCKET FOR BACKUPS
# ============================================

resource "aws_s3_bucket" "phoenix_backups" {
  bucket = "phoenix-backups-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "phoenix-backups"
  }
}

resource "aws_s3_bucket_versioning" "phoenix_backups_versioning" {
  bucket = aws_s3_bucket.phoenix_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "phoenix_backups_sse" {
  bucket = aws_s3_bucket.phoenix_backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================
# 6. CLOUDWATCH MONITORING
# ============================================

# CloudWatch alarm to stop EC2 when idle (cost optimization)
resource "aws_cloudwatch_metric_alarm" "ec2_idle_stop" {
  alarm_name          = "phoenix-ec2-idle-stop"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "Stop EC2 instance when CPU utilization is below 5% for 10 minutes"
  alarm_actions       = [aws_sns_topic.phoenix_notifications.arn]

  dimensions = {
    InstanceId = aws_instance.phoenix_ec2.id
  }
}

# RDS CPU monitoring
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "phoenix-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when RDS CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.phoenix_notifications.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.phoenix_postgres.id
  }
}

# ============================================
# 7. SNS NOTIFICATIONS
# ============================================

resource "aws_sns_topic" "phoenix_notifications" {
  name = "phoenix-notifications"

  tags = {
    Name = "phoenix-notifications"
  }
}

resource "aws_sns_topic_subscription" "phoenix_email" {
  topic_arn = aws_sns_topic.phoenix_notifications.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ============================================
# 8. DATA SOURCES
# ============================================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}
