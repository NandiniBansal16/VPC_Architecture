# Deploy Scalable VPC Architecture on AWS

## Project Overview
Designed and deployed a production-grade, highly available VPC architecture on AWS using the AWS CLI. The infrastructure hosts a web application behind an Application Load Balancer with Auto Scaling across multiple Availability Zones.

## Architecture Diagram
<img width="2720" height="2880" alt="vpc_architecture_diagram (1)" src="https://github.com/user-attachments/assets/478b7e24-524a-4f53-b345-9de43e71e894" />

## Tech Stack
| Category | Tools |
|---|---|
| Cloud Provider | AWS |
| Networking | VPC, Subnets, IGW, NAT Gateway, Transit Gateway |
| Compute | EC2, Auto Scaling Group, Launch Template, Golden AMI |
| Load Balancing | Application Load Balancer (ALB) |
| Security | Security Groups, Bastion Host, IAM Roles |
| Monitoring | CloudWatch, VPC Flow Logs |
| Storage | S3 |
| Access | AWS Session Manager, SSM Agent |
| CLI | AWS CLI |

## Architecture Components

### VPCs
- **App VPC** (172.32.0.0/16) — hosts all application infrastructure
- **Bastion VPC** (192.168.0.0/16) — hosts the jump server for secure SSH access

### Networking
- **2 Public Subnets** — ALB and NAT Gateway
- **2 Private Subnets** — App servers (never directly exposed to internet)
- **Internet Gateway** — public internet access
- **NAT Gateway** — private instances can reach internet (for updates/git clone)
- **Transit Gateway** — connects App VPC and Bastion VPC

### Compute
- **Golden AMI** — pre-baked Ubuntu AMI with Apache, AWS CLI, Git, CloudWatch Agent, SSM Agent
- **Launch Template** — standardized EC2 configuration with userdata
- **Auto Scaling Group** — min 2, max 4 instances across 2 AZs
- **Scaling Policy** — target tracking at 70% CPU

### Security
- **Bastion Host** with Elastic IP — only entry point for SSH
- **Security Groups** — least privilege (app servers only accept traffic from ALB and Bastion)
- **IAM Role** — EC2 instances have S3 read and SSM access only
- **VPC Flow Logs** — all network traffic logged to CloudWatch

## Prerequisites
- AWS Account with CLI access
- AWS CLI installed and configured
- Git

## Deployment Steps

### 1. Clone the repository
```bash
git clone https://github.com/NandiniBansal16/VPC_Architecture.git
cd VPC_Architecture
```

### 2. Configure AWS CLI
```bash
aws configure
```

### 3. Run infrastructure setup
Follow the step-by-step commands in `scripts/setup-vpc.sh`

### 4. Verify deployment
```bash
source scripts/recover-vars.sh
aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]' \
  --output table
```

### 5. Access the website
```
http://http://app-alb-649362763.us-east-1.elb.amazonaws.com/
```

## 🔐 Security Design

Internet → ALB (port 80) → App Servers (port 80 from ALB only)
↑
Bastion Host (port 22 from Bastion VPC only)
↑
Engineer (SSH with key pair)

## 💰 Cost Optimization
- t3.micro instances (free tier eligible)
- Auto Scaling ensures no over-provisioning
- NAT Gateway shared across all private instances

## 🧹 Cleanup
To avoid AWS charges, delete resources in this order:
1. Auto Scaling Group
2. Load Balancer & Target Group
3. NAT Gateway & Elastic IPs
4. Transit Gateway & Attachments
5. EC2 instances & AMI
6. VPCs & all networking components
