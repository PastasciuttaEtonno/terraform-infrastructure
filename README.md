# Terraform Multi-Region Infrastructure

This Terraform configuration deploys a multi-region AWS infrastructure with auto-scaling web applications, load balancers, and CloudFront distribution.

## Project Structure

### Root Level Files

**main.tf**
The orchestration file that defines providers for primary and DR regions. It instantiates the app-stack module twice - once for each region. Contains CloudFront distribution configuration that sits in front of both regional deployments.

**variables.tf**
Defines input variables for the entire project including region settings, instance types, SSH keys, and sensitive values like CloudFront secrets. These variables are consumed by main.tf and passed down to modules.

**terraform.tfvars.example**
Template file showing required variable values. Copy this to terraform.tfvars and fill in your actual values.

**instance.txt**
Standalone EC2 instance configuration (appears to be legacy/example code). Not used by the main infrastructure.

### Module: app-stack

The core infrastructure module located in `modules/app-stack/`. This module creates a complete application stack in a single region.

**vpc.tf**
Creates the Virtual Private Cloud with DNS resolution enabled. This is the network foundation for all other resources.

**subnets.tf**
Defines public subnets across multiple availability zones using the subnet configuration map. Subnets are dynamically created based on the target region.

**route_tables.tf**
Sets up routing between subnets and the internet gateway, enabling public internet access for resources in public subnets.

**security_groups.tf**
Defines firewall rules for web instances, allowing HTTP (80), HTTPS (443), SSH (22), and application traffic on the configured port.

**alb.tf**
Application Load Balancer configuration with target groups, listeners, and routing rules. Includes custom header validation for CloudFront integration.

**asg.tf**
Auto Scaling Group with launch template. Manages EC2 instances that run the application, automatically scaling based on demand.

**iam.tf**
IAM roles and policies for EC2 instances to access ECR repositories and other AWS services securely.

**ecr.tf**
Elastic Container Registry for storing Docker images. Configured with encryption and lifecycle policies.

**dynamodb.tf**
DynamoDB table for application data storage with point-in-time recovery enabled.

**data.tf**
Data sources that fetch information from AWS, such as the latest Amazon Linux AMI for the target region.

**variables.tf**
Module-specific variables including networking configuration, resource names, and regional settings.

**outputs.tf**
Exposes important resource information (ALB DNS, VPC ID, etc.) for use by the root module or external systems.

**providers.tf**
Defines required provider versions for the module.

## How Components Interact

### Data Flow
1. **terraform.tfvars** provides actual values
2. **variables.tf** defines variable structure and validation
3. **main.tf** consumes variables and passes them to modules
4. **app-stack module** creates regional infrastructure using passed variables
5. **outputs.tf** exposes resource information back to main.tf
6. **main.tf** uses module outputs to configure CloudFront

### Network Architecture
1. **VPC** provides isolated network environment
2. **Subnets** segment the network across availability zones
3. **Internet Gateway + Route Tables** enable internet connectivity
4. **Security Groups** control traffic flow
5. **ALB** distributes traffic to healthy instances
6. **Auto Scaling Group** manages instance lifecycle
7. **CloudFront** provides global content delivery

### Security Integration
1. **IAM roles** provide least-privilege access
2. **Security groups** implement network-level security
3. **ECR** stores container images securely
4. **Custom headers** secure ALB-CloudFront communication

## Deployment Regions

**Primary Region (us-east-1)**
Active deployment handling production traffic with full auto-scaling enabled.

**DR Region (us-east-2)**
Disaster recovery deployment with minimal capacity, ready to scale up if primary region fails.

## Usage

1. Copy terraform.tfvars.example to terraform.tfvars
2. Fill in your actual values (SSH keys, secrets)
3. Run terraform init to initialize
4. Run terraform plan to review changes
5. Run terraform apply to deploy infrastructure

The configuration automatically handles cross-region coordination and ensures consistent deployments across both regions.