# =============================================================================
# VIRTUAL PRIVATE CLOUD (VPC)
# =============================================================================
# Definisce la rete virtuale isolata dove verranno lanciate tutte le risorse AWS.
# È il contenitore di rete fondamentale per la tua infrastruttura.

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block

  # Abilita la risoluzione DNS all'interno della VPC, permettendo alle istanze
  # di comunicare tra loro usando i nomi DNS.
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  # Tag di metadati per identificare la VPC.
  tags = {
    Name        = "${var.aws_region}-main-vpc"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# =============================================================================
# INTERNET GATEWAY (IGW)
# =============================================================================
# Crea un Internet Gateway e lo collega alla VPC. L'IGW è una componente
# gestita da AWS che permette la comunicazione tra le risorse nella VPC
# e Internet.

resource "aws_internet_gateway" "main_igw" {
  # Associa l'Internet Gateway alla VPC creata sopra.
  vpc_id = aws_vpc.main_vpc.id

  # Tag di metadati per identificare l'IGW.
  tags = {
    Name = "${var.aws_region}-main-igw"
  }
}