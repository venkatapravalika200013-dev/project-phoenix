# Project Phoenix: AWS Production Stack Simulation

**Comprehensive Infrastructure-as-Code deployment for AWS production environment with full automation, monitoring, and disaster recovery capabilities.**

---

## 📋 Overview

Project Phoenix is a complete AWS infrastructure simulation project demonstrating enterprise-grade DevOps practices. Built with **Terraform IaC**, it provisions a production-ready stack including EC2 compute, RDS database, S3 storage, networking, security, monitoring, and notifications.

**First Deployed:** June 14, 2026  
**Status:** ✅ Production Ready  
**Maintained By:** Pravalika Dasika

---

## 🎯 Project Objectives

✅ Demonstrate **Infrastructure-as-Code mastery** using Terraform  
✅ Provision **production-grade AWS infrastructure** with best practices  
✅ Implement **automated monitoring & alerting** via CloudWatch & SNS  
✅ Practice **disaster recovery & backup strategies**  
✅ Document **deployment processes** and error handling  
✅ Create **reusable, scalable infrastructure modules**  

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Region (ap-south-1)              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         VPC (10.0.0.0/16)                           │   │
│  │                                                       │   │
│  │  ┌─────────────────┐    ┌─────────────────────────┐ │   │
│  │  │ Public Subnet   │    │ Private Subnet          │ │   │
│  │  │ (10.0.1.0/24)   │    │ (10.0.2.0/24)           │ │   │
│  │  │                 │    │                         │ │   │
│  │  │ ┌───────────┐   │    │ ┌─────────────────────┐ │ │   │
│  │  │ │   EC2     │   │    │ │   RDS PostgreSQL    │ │ │   │
│  │  │ │ t3.micro  │   │    │ │ db.t3.micro         │ │ │   │
│  │  │ │           │   │    │ │ (Multi-AZ Backup)   │ │ │   │
│  │  │ │ XFCE/VNC  │   │    │ │ 7-day retention     │ │ │   │
│  │  │ │ Docker    │   │    │ │ Encrypted Storage   │ │ │   │
│  │  │ │ Terraform │   │    │ │ CloudWatch Logs     │ │ │   │
│  │  │ │ Tools     │   │    │ │                     │ │ │   │
│  │  │ └───────────┘   │    │ └─────────────────────┘ │ │   │
│  │  │                 │    │                         │ │   │
│  │  │ ┌─────────────┐ │    │ ┌──────────────────┐    │ │   │
│  │  │ │ Elastic IP  │ │    │ │ Security Group   │    │ │   │
│  │  │ │ (Static)    │ │    │ │ Port 5432 (PG)   │    │ │   │
│  │  │ └─────────────┘ │    │ └──────────────────┘    │ │   │
│  │  └─────────────────┘    └─────────────────────────┘ │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │ Internet Gateway                             │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  │                                                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ CloudWatch Monitoring & Alarms                       │   │
│  │ - EC2 CPU Idle Detection (auto-stop)               │   │
│  │ - RDS CPU High Alert (>80%)                        │   │
│  │ - Database Logs Export                             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ SNS Topic → Email Notifications                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ S3 Bucket: Backup & Storage (versioning enabled)   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Infrastructure Components

### 1. **Networking (VPC)**
- VPC with public & private subnets across 2 AZs
- Internet Gateway for outbound/inbound traffic
- Route tables with proper isolation
- Network ACLs for security

### 2. **Compute (EC2)**
- Instance Type: **t3.micro** (free tier eligible)
- OS: **Ubuntu 22.04 LTS**
- Elastic IP for stable public access
- Root volume: 20GB gp3, encrypted
- Monitoring: CloudWatch enabled
- Software pre-installed: Docker, XFCE, TigerVNC, DevOps tools

### 3. **Database (RDS)**
- Engine: **PostgreSQL 15.3**
- Instance: **db.t3.micro** (free tier eligible)
- Storage: 20GB gp3, encrypted
- Backup: 7-day retention, automated snapshots
- Logging: CloudWatch Logs export enabled
- Security: VPC security group, no public access
- Multi-AZ capable for high availability

### 4. **Storage (S3)**
- Versioning enabled for data protection
- Server-side encryption (AES256)
- Object lifecycle policies (future)
- Used for database backups & artifacts

### 5. **Monitoring & Alerting**
- **CloudWatch Alarms:**
  - EC2 CPU idle detection (auto-stop for cost optimization)
  - RDS CPU high threshold (>80%)
  - Database logs export to CloudWatch Logs
- **SNS Topic:** Email notifications for all alarms
- **Dashboard:** Monitor all metrics in one view

### 6. **Security**
- Security Groups: Separate for EC2 & RDS
- SSH access: Port 22 (restricted CIDR)
- VNC access: Port 5901 (restricted CIDR)
- RDS: Private subnet, no public access
- Encryption: All storage encrypted at rest
- IAM: Least privilege (via default tags)

---

## 📦 Prerequisites

### Local Machine:
- Terraform >= 1.0
- AWS CLI v2
- AWS credentials configured (`~/.aws/credentials`)
- SSH key pair (generate with: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/phoenix-key`)
- Text editor or IDE (VS Code recommended)

### AWS Account:
- Active AWS account with sufficient permissions
- EC2, RDS, VPC, S3, CloudWatch, SNS services available
- Free tier eligible resources (t3.micro EC2, db.t3.micro RDS)

---

## 🚀 Deployment Guide

### Step 1: Clone Repository
```bash
git clone https://github.com/venkatapravalika200013-dev/project-phoenix.git
cd project-phoenix
```

### Step 2: Configure Variables
Create `terraform.tfvars` with your values:
```hcl
aws_region       = "ap-south-1"
vpc_cidr          = "10.0.0.0/16"
instance_type     = "t3.micro"
db_instance_type  = "db.t3.micro"
db_password       = "GenerateSecurePassword123!" # Use: openssl rand -base64 16
alert_email       = "your-email@example.com"
public_key_path   = "~/.ssh/phoenix-key.pub"
```

### Step 3: Initialize Terraform
```bash
terraform init
```

### Step 4: Plan Deployment
```bash
terraform plan -out=tfplan
```

Review the plan for expected resources.

### Step 5: Apply Configuration
```bash
terraform apply tfplan
```

**Deployment time:** ~10-15 minutes

### Step 6: Retrieve Outputs
```bash
terraform output
```

Example outputs:
```
ec2_public_ip = "52.xxx.xxx.xxx"
ec2_ssh_command = "ssh -i ~/.ssh/phoenix-key.pem ubuntu@52.xxx.xxx.xxx"
ec2_vnc_connection = "52.xxx.xxx.xxx:5901"
rds_endpoint = "phoenix-postgres-db.xxxxx.ap-south-1.rds.amazonaws.com:5432"
```

---

## 🖥️ Access Methods

### SSH Access
```bash
ssh -i ~/.ssh/phoenix-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### VNC Access (Desktop)
1. Install VNC viewer (TigerVNC, RealVNC, or similar)
2. Connect to: `<EC2_PUBLIC_IP>:5901`
3. Password: Use value from `vnc_password` variable
4. Access XFCE desktop with pre-installed DevOps tools

### Database Access
```bash
psql -h <RDS_ENDPOINT> -U adminuser -d phoenixdb
```

---

## 📊 Monitoring & Alarms

### CloudWatch Metrics
- **EC2 CPU Utilization:** Monitored every 5 minutes
- **RDS CPU Utilization:** Alert if > 80% for 10 minutes
- **RDS Storage Used:** Track database growth
- **Database Connections:** Monitor active connections

### Auto-Stop Feature
EC2 instance automatically stops after 10 minutes of idle CPU (<5%), reducing costs.

### SNS Notifications
All alarms send email notifications. Verify subscription in your email.

---

## 🔄 Common Operations

### Update Infrastructure
```bash
# Modify terraform.tfvars
vim terraform.tfvars

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

### Destroy Infrastructure
```bash
terraform destroy -auto-approve
```

⚠️ **Warning:** This deletes all resources. Ensure data is backed up first.

### Backup Database
```bash
# Manual snapshot via AWS CLI
aws rds create-db-snapshot \
  --db-instance-identifier phoenix-postgres-db \
  --db-snapshot-identifier phoenix-backup-$(date +%Y%m%d)
```

### Scale Resources
```hcl
# In terraform.tfvars, change:
instance_type     = "t3.small"      # Scale up EC2
db_instance_type  = "db.t3.small"   # Scale up RDS

# Apply
terraform apply
```

---

## 📝 Error Handling & Troubleshooting

See **PROJECT_PHOENIX_ERROR_LOG.md** for detailed error documentation including:
- Root cause analysis for each error
- Prevention strategies
- Solutions implemented
- Future improvement recommendations

### Common Issues:

**1. "bash not found on Windows"**
- Solution: Use Terraform CLI directly instead of bash scripts

**2. "Duplicate keypair error"**
- Solution: `terraform state rm aws_key_pair.phoenix_key` then reapply

**3. "File access denied writing .pem"**
- Solution: Delete existing file before redeployment

**4. "Terraform state out of sync"**
- Solution: `terraform refresh` to sync state with AWS

---

## 📈 Cost Estimation

| Resource | Type | Estimated Cost/Month |
|----------|------|----------------------|
| EC2 (t3.micro) | Compute | Free (750 hrs/month) |
| RDS (db.t3.micro) | Database | Free (750 hrs/month) |
| S3 (Backup) | Storage | ~$0.50 (assuming <1GB) |
| Data Transfer | Network | ~$0 (within VPC) |
| **Total** | | **~$0.50/month** |

✅ **Production infrastructure for minimal cost!**

---

## 🎓 Learning Outcomes

This project demonstrates:

✅ **Terraform IaC Mastery:**
- 18+ resource types
- Modular design patterns
- State management & backend configuration
- Variables, outputs, locals
- Sensitive data handling

✅ **AWS Best Practices:**
- VPC design with public/private subnets
- Security groups & network isolation
- Encryption at rest & in transit
- IAM roles & policies
- Cost optimization (auto-stop, free tier)

✅ **DevOps Fundamentals:**
- Infrastructure automation
- Monitoring & alerting
- Backup & disaster recovery
- Documentation discipline
- Error tracking & prevention

✅ **Production Readiness:**
- High availability patterns
- Automated backups
- Health monitoring
- Incident alerting
- Scalable architecture

---

## 📚 Documentation

Related files in this repository:
- **DEPLOYMENT_GUIDE.md** - Step-by-step deployment instructions
- **PROJECT_PHOENIX_ERROR_LOG.md** - Complete error documentation
- **PROJECT_PHOENIX_ROADMAP.md** - Future enhancements & learning path
- **terraform.tfvars.example** - Example variable configuration

---

## 🔐 Security Notes

⚠️ **Production Deployment Checklist:**
- [ ] Change `allowed_ssh_cidr` from `0.0.0.0/0` to your IP
- [ ] Change `allowed_vnc_cidr` from `0.0.0.0/0` to your IP
- [ ] Use strong database password (generate: `openssl rand -base64 16`)
- [ ] Enable S3 bucket versioning & MFA delete
- [ ] Configure remote Terraform state (S3 backend)
- [ ] Enable VPC Flow Logs for network monitoring
- [ ] Implement GuardDuty for threat detection
- [ ] Set up CloudTrail for API auditing

---

## 👨‍💻 Author & Support

**Created by:** Pravalika Dasika  
**AWS Certifications:** Cloud Practitioner, Developer Associate  
**Email:** venkatapravalika200013@gmail.com  
**LinkedIn:** linkedin.com/in/pravalika-dasika-21736938a  

---

## 📄 License

This project is provided as-is for educational and portfolio purposes. Free to use, modify, and distribute.

---

## 🚀 Next Steps

1. **Deploy this infrastructure** in your AWS account
2. **Experiment:** Scale resources, add monitoring, implement backups
3. **Learn:** Study Terraform best practices through this code
4. **Extend:** Add more resources (API Gateway, Lambda, etc.)
5. **Share:** Showcase this in job interviews & portfolio

---

**Last Updated:** June 14, 2026  
**Status:** ✅ Production Ready | Fully Documented | Cost Optimized

Happy Infrastructure Building! 🎯
