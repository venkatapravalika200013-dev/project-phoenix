# Project Phoenix - Terraform Variables
# Define all configurable parameters

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# ============================================
# NETWORKING
# ============================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# ============================================
# SECURITY
# ============================================

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change to your IP for production
}

variable "allowed_vnc_cidr" {
  description = "CIDR blocks allowed for VNC access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change to your IP for production
}

variable "public_key_path" {
  description = "Path to public key for EC2 key pair"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# ============================================
# EC2 CONFIGURATION
# ============================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # Free tier eligible
}

variable "vnc_password" {
  description = "VNC server password"
  type        = string
  sensitive   = true
  default     = "Phoenix@2026"
}

# ============================================
# RDS CONFIGURATION
# ============================================

variable "db_instance_type" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro" # Free tier eligible
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "adminuser"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  # Generate secure password: $(openssl rand -base64 16)
}

# ============================================
# NOTIFICATIONS
# ============================================

variable "alert_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
  default     = "venkatapravalika200013@gmail.com"
}

# ============================================
# TAGS
# ============================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Project-Phoenix"
    Owner       = "Pravalika Dasika"
    Terraform   = "true"
    Environment = "Production"
  }
}
