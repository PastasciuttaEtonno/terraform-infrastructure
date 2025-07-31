# =============================================================================
# VARIABILI DI CONFIGURAZIONE GLOBALE
# =============================================================================
# Definisce le variabili di alto livello per l'intero progetto multi-regione.

variable "primary_region" {
  description = "La regione AWS primaria (attiva)."
  type        = string
  default     = "us-east-1"
}

variable "dr_region" {
  description = "La regione AWS di Disaster Recovery (passiva)."
  type        = string
  default     = "us-east-2" 
}

# =============================================================================
# VARIABILI COMUNI PASSATE AL MODULO
# =============================================================================
# Definite qui per garantire coerenza tra le due regioni.

variable "project_name" {
  description = "Un nome base per il progetto, usato come prefisso per le risorse."
  type        = string
  default     = "my-app"
}

variable "instance_type" {
  description = "Il tipo di istanza EC2 da lanciare."
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Il nome della coppia di chiavi EC2 per l'accesso SSH."
  type        = string
  # SECURITY: No default value - must be provided at runtime
}

variable "app_port" {
  description = "La porta su cui l'applicazione è in ascolto all'interno dell'istanza EC2."
  type        = number
  default     = 7000
}

variable "cloudfront_secret_header_value" {
  description = "Valore segreto per l'header di comunicazione tra CloudFront e ALB."
  type        = string
  sensitive   = true
  # SECURITY: No default value - must be provided at runtime or via terraform.tfvars
}
