# =============================================================================
# GRUPPI DI SICUREZZA (SECURITY GROUPS)
# =============================================================================
resource "aws_security_group" "web_sg" {
  name        = "${var.asg_name}-web-sg"
  description = "Security group for web instances"
  vpc_id      = aws_vpc.main_vpc.id

  # --- Regole di Traffico in Entrata (Ingress) ---

  # Regola per l'accesso SSH (porta 22) per la gestione del server.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ LIMITARE ALL'IP DELL'UFFICIO IN PRODUZIONE!
    description = "Allow SSH access from trusted IPs"
  }

  # Regola per il traffico dall'ALB.
  # Permette traffico solo dal Security Group dell'ALB sulla porta dell'app.
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # <-- MODIFICA CRUCIALE
    description     = "Allow traffic from ALB"
  }

  # --- Regola di Traffico in Uscita (Egress) ---
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.asg_name}-web-sg"
  }
}
