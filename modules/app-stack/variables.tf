# =============================================================================
# VARIABILI DI INPUT DEL MODULO APP-STACK
# =============================================================================
# Definisce l'interfaccia del modulo, dichiarando tutte le variabili
# che possono essere passate dall'orchestratore root.

# =============================================================================
# VARIABILI DI CONFIGURAZIONE GENERALE E DI CONTESTO
# =============================================================================

variable "aws_region" {
  description = "La regione AWS in cui questo modulo creerà le risorse."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome base per le risorse."
  type        = string
  default     = "default-project"
}

variable "is_dr_region" {
  description = "Flag booleano che indica se questo deploy è per la regione di DR."
  type        = bool
  default     = false
}

variable "dr_region_name" {
  description = "Il nome della regione di DR (necessario per la replica di DynamoDB)."
  type        = string
  default     = "" # Opzionale, passato solo dalla regione primaria
}

variable "account_id" {
  description = "L'ID dell'account AWS."
  type        = string
  default     = null
}

# =============================================================================
# VARIABILI PER EC2 E AUTO SCALING GROUP (ASG)
# =============================================================================

variable "instance_type" {
  description = "Tipo di istanza EC2."
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Nome della chiave SSH."
  type        = string
  # SECURITY: No default value - must be provided by parent module
}

variable "asg_name" {
  description = "Il nome per l'Auto Scaling Group."
  type        = string
  default     = "my-app-asg"
}

variable "asg_min_size" {
  description = "Numero minimo di istanze nell'ASG."
  type        = number
}

variable "asg_max_size" {
  description = "Numero massimo di istanze nell'ASG."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Numero desiderato di istanze nell'ASG."
  type        = number
}

# =============================================================================
# VARIABILI PER APPLICATION LOAD BALANCER (ALB) E APPLICAZIONE
# =============================================================================

variable "app_port" {
  description = "Porta dell'applicazione."
  type        = number
  default     = 80
}

variable "alb_name" {
  description = "Il nome per l'Application Load Balancer."
  type        = string
  default     = "my-app-alb"
}

variable "alb_target_group_name" {
  description = "Il nome per il Target Group dell'ALB."
  type        = string
  default     = "my-app-tg"
}

# =============================================================================
# VARIABILI PER CLOUDFRONT
# =============================================================================

variable "cloudfront_secret_header_value" {
  description = "Valore segreto per l'header di CloudFront."
  type        = string
  sensitive   = true
  # SECURITY: No default value - must be provided by parent module
}

# =============================================================================
# VARIABILI PER NETWORKING, IAM, ECR, DYNAMODB (CON DEFAULT)
# =============================================================================
# Queste variabili hanno valori di default e non devono essere passate
# dal modulo root, a meno che non si voglia personalizzarle.

variable "vpc_cidr_block" {
  description = "Il blocco CIDR per la VPC."
  type        = string
  default     = "172.31.0.0/16"
}

variable "subnet_config" {
  description = "Mappa delle subnet per regione."
  type        = map(map(string))
  default = {
    "us-east-1" = {
      "us-east-1a" = "172.31.0.0/20",
      "us-east-1b" = "172.31.16.0/20",
      "us-east-1c" = "172.31.32.0/20",
      "us-east-1d" = "172.31.48.0/20",
      "us-east-1e" = "172.31.64.0/20",
      "us-east-1f" = "172.31.80.0/20"
    },
    "us-east-2" = {
      "us-east-2a" = "172.31.0.0/20",
      "us-east-2b" = "172.31.16.0/20",
      "us-east-2c" = "172.31.32.0/20",
    },
    "eu-central-1" = {
      "eu-central-1a" = "10.0.1.0/24",
      "eu-central-1b" = "10.0.2.0/24",
      "eu-central-1c" = "10.0.3.0/24"
    },
    "eu-north-1" = {
      "eu-north-1a" = "10.1.1.0/24",
      "eu-north-1b" = "10.1.2.0/24",
      "eu-north-1c" = "10.1.3.0/24"
    }
  }
}

variable "ecr_repository_name" {
  description = "Il nome per il repository ECR."
  type        = string
  default     = "my-terraform"
}

variable "app_image_tag" {
  description = "Il tag dell'immagine Docker da deployare (es. 'latest' o 'v1.0')."
  type        = string
  default     = "latest"
}

variable "iam_role_name" {
  description = "Il nome per il Ruolo IAM dell'istanza EC2."
  type        = string
  default     = "ec2-instance-role"
}

variable "iam_ecr_policy_name" {
  description = "Il nome per la Policy IAM personalizzata che garantisce l'accesso a ECR."
  type        = string
  default     = "ec2-ecr-access-policy"
}

variable "iam_instance_profile_name" {
  description = "Il nome per il Profilo di Istanza EC2."
  type        = string
  default     = "ec2-test-terraform"
}

variable "dynamodb_table_name" {
  description = "Il nome per la tabella DynamoDB."
  type        = string
  default     = "my-app-data"
}
