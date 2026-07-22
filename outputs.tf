# Project Phoenix - Terraform Outputs
# Display key infrastructure details after deployment

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.phoenix_vpc.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.phoenix_public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.phoenix_private.id
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.phoenix_ec2.id
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = aws_eip.phoenix_eip.public_ip
}

output "ec2_private_ip" {
  description = "EC2 private IP address"
  value       = aws_instance.phoenix_ec2.private_ip
}

output "ec2_ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i ~/.ssh/phoenix-key.pem ubuntu@${aws_eip.phoenix_eip.public_ip}"
}

output "ec2_vnc_connection" {
  description = "VNC connection string"
  value       = "${aws_eip.phoenix_eip.public_ip}:5901"
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.phoenix_postgres.endpoint
}

output "rds_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${var.db_username}@${aws_db_instance.phoenix_postgres.endpoint}:5432/${aws_db_instance.phoenix_postgres.db_name}"
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.phoenix_postgres.db_name
}

output "s3_bucket_name" {
  description = "S3 bucket for backups"
  value       = aws_s3_bucket.phoenix_backups.id
}

output "cloudwatch_alarm_cpu_idle" {
  description = "CloudWatch alarm for idle EC2"
  value       = aws_cloudwatch_metric_alarm.ec2_idle_stop.alarm_name
}

output "cloudwatch_alarm_rds_cpu" {
  description = "CloudWatch alarm for RDS CPU"
  value       = aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name
}

output "sns_topic_arn" {
  description = "SNS topic for notifications"
  value       = aws_sns_topic.phoenix_notifications.arn
}

output "security_group_ec2_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.phoenix_ec2_sg.id
}

output "security_group_rds_id" {
  description = "RDS security group ID"
  value       = aws_security_group.phoenix_rds_sg.id
}

output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    "VPC"                  = aws_vpc.phoenix_vpc.id
    "EC2 Instance ID"      = aws_instance.phoenix_ec2.id
    "EC2 Public IP"        = aws_eip.phoenix_eip.public_ip
    "EC2 Access Methods"   = "SSH (port 22) | VNC (port 5901)"
    "RDS Database"         = aws_db_instance.phoenix_postgres.db_name
    "RDS Endpoint"         = aws_db_instance.phoenix_postgres.endpoint
    "S3 Backup Bucket"     = aws_s3_bucket.phoenix_backups.id
    "CloudWatch Alarms"    = 2
    "SNS Notifications"    = aws_sns_topic.phoenix_notifications.arn
    "Deployment Status"    = "✅ Production Ready"
  }
}
