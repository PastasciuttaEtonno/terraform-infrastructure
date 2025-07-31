# =============================================================================
# DATA SOURCES
# =============================================================================
# Le data source recuperano informazioni da AWS che possono essere utilizzate
# nel resto della configurazione Terraform.

# Trova l'ultima versione dell'AMI di Amazon Linux 2023 per la regione
# selezionata. Questo garantisce di usare sempre un'immagine aggiornata.
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
