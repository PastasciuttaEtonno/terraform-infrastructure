# =============================================================================
# ORCHESTRAZIONE MULTI-REGIONE
# =============================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# --- Configurazione dei Provider AWS ---
provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

# --- Data Source per ottenere l'Account ID ---
data "aws_caller_identity" "current" {
  provider = aws.primary
}

# --- Deploy nella Regione Primaria (ATTIVA) ---
module "primary_stack" {
  source = "./modules/app-stack"
  providers = {
    aws = aws.primary
  }

  aws_region             = var.primary_region
  asg_min_size           = 1
  asg_max_size           = 3
  asg_desired_capacity   = 1
  is_dr_region           = false
  dr_region_name         = var.dr_region
  
  project_name                   = var.project_name
  instance_type                  = var.instance_type
  ssh_key_name                   = var.ssh_key_name
  app_port                       = var.app_port
  cloudfront_secret_header_value = var.cloudfront_secret_header_value
  account_id                     = data.aws_caller_identity.current.account_id
}

# --- Deploy nella Regione di DR (PASSIVA / "Pilot Light") ---
module "dr_stack" {
  source = "./modules/app-stack"
  providers = {
    aws = aws.dr
  }

  aws_region             = var.dr_region
  asg_min_size           = 0
  asg_max_size           = 0
  asg_desired_capacity   = 0
  is_dr_region           = true

  project_name                   = var.project_name
  instance_type                  = var.instance_type
  ssh_key_name                   = var.ssh_key_name
  app_port                       = var.app_port
  cloudfront_secret_header_value = var.cloudfront_secret_header_value
  account_id                     = data.aws_caller_identity.current.account_id
}

# =============================================================================
# CLOUDFRONT DISTRIBUTION (DEFINITA QUI NEL ROOT)
# =============================================================================
resource "aws_cloudfront_distribution" "main_distribution" {
  # CloudFront è una risorsa globale, ma deve essere creata tramite un provider.
  # Usiamo il provider primario.
  provider = aws.primary
  
  enabled = true
  comment = "CDN for ${var.project_name}"
  
  origin_group {
    origin_id = "failover-group"
    failover_criteria {
      status_codes = [500, 502, 503, 504]
    }
    member {
      origin_id = "primary-${var.project_name}"
    }
    member {
      origin_id = "dr-${var.project_name}"
    }
  }

  origin {
    domain_name = module.primary_stack.alb_dns_name # <-- Prende l'output dal modulo
    origin_id   = "primary-${var.project_name}"
    
    custom_header {
      name  = "X-Custom-Header"
      value = var.cloudfront_secret_header_value
    }
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = module.dr_stack.alb_dns_name # <-- Prende l'output dal modulo
    origin_id   = "dr-${var.project_name}"

    custom_header {
      name  = "X-Custom-Header"
      value = var.cloudfront_secret_header_value
    }
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "failover-group"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
