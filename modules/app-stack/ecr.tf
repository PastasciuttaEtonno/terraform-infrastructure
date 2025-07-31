# =============================================================================
# REPOSITORY ECR (ELASTIC CONTAINER REGISTRY)
# =============================================================================
# Definisce il repository Docker privato dove verranno archiviate 
# le immagini dell'applicazione.

resource "aws_ecr_repository" "app_repository" {
  name = var.ecr_repository_name # Nome del repository dalla variabile

  # --- Configurazione della Crittografia ---
  encryption_configuration {
    encryption_type = "AES256" # Crittografia a riposo gestita da AWS (standard)
  }

  # --- Configurazione della Scansione Immagini ---
  image_scanning_configuration {
    scan_on_push = false # Abilita/disabilita la scansione automatica delle vulnerabilità all'upload
                         # (consigliato 'true' per maggiore sicurezza in produzione)
  }

  # --- Configurazione della Mutabilità dei Tag ---
  # 'MUTABLE' permette di sovrascrivere un tag immagine (es. latest) con una nuova immagine.
  # 'IMMUTABLE' impedisce la sovrascrittura, garantendo che un tag si riferisca sempre
  # alla stessa, unica immagine (consigliato per ambienti di produzione).
  image_tag_mutability = "MUTABLE"

  # --- Tag di Metadati per la Risorsa ---
  tags = {
    Name        = "${var.aws_region}-${var.ecr_repository_name}"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}