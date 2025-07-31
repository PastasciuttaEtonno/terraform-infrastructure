# iam.tf (Nuovo modo, più sicuro e pulito)

# =============================================================================
# RUOLO IAM PER L'ISTANZA EC2
# =============================================================================
resource "aws_iam_role" "ec2_role" {
  name = var.iam_role_name

  # Policy che permette al servizio EC2 di "assumere" questo ruolo
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name      = "${var.aws_region}-${var.iam_role_name}"
    ManagedBy = "Terraform"
  }
}

# =============================================================================
# POLICY ATTACHMENTS
# =============================================================================

# 1. ATTACH DELLA POLICY GESTITA DA AWS PER SSM CORE
#    Questa è la best practice. AWS la mantiene aggiornata per te.
resource "aws_iam_role_policy_attachment" "ssm_managed_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  # ARN della policy gestita da AWS per le funzionalità base di Systems Manager
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 2. POLICY PERSONALIZZATA PER L'ACCESSO A ECR
#    Creiamo una policy separata solo per i permessi specifici della nostra app.
resource "aws_iam_policy" "ecr_access_policy" {
  name        = var.iam_ecr_policy_name # Puoi rinominare la variabile in "ecr_policy_name" per più chiarezza
  description = "IAM policy for EC2 instance to access a specific ECR repository"

  # Definiamo i permessi solo per ECR, puntando alla risorsa specifica.
  # NOTA: Assicurati che la risorsa 'aws_ecr_repository.app_repository' sia definita in un altro file (es. ecr.tf)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [aws_ecr_repository.app_repository.arn] # <-- Permesso specifico, eccellente!
      }
      # !! NOTA: I permessi S3 generici sono stati rimossi. Se l'istanza
      # !! deve accedere a un bucket S3, aggiungi qui un nuovo statement
      # !! con l'ARN specifico di quel bucket per massima sicurezza.
      #
      # Esempio di permesso S3 sicuro:
      # {
      #   Sid = "S3AccessToSpecificBucket",
      #   Effect = "Allow",
      #   Action = "s3:GetObject",
      #   Resource = "arn:aws:s3:::nome-del-tuo-bucket/*"
      # }
    ]
  })

  tags = {
    Name      = "${var.aws_region}-${var.iam_ecr_policy_name}"
    ManagedBy = "Terraform"
  }
}

# 3. ATTACH DELLA POLICY PERSONALIZZATA DI ECR AL RUOLO
resource "aws_iam_role_policy_attachment" "ecr_custom_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# =============================================================================
# PROFILO ISTANZA
# =============================================================================
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.ec2_role.name

  tags = {
    Name      = "${var.aws_region}-${var.iam_instance_profile_name}"
    ManagedBy = "Terraform"
  }
}