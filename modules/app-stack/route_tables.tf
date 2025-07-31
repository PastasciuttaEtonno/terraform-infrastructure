# =============================================================================
# TABELLE DI ROTTA (ROUTE TABLES)
# =============================================================================
# Definisce le regole di instradamento per il traffico di rete della VPC.
# Questa tabella di rotta "pubblica" specifica che tutto il traffico diretto
# verso l'esterno (Internet) deve passare attraverso l'Internet Gateway.
# Verrà associata alle subnet pubbliche.

resource "aws_route_table" "public_route_table" {
  # Associa questa tabella di rotta alla VPC principale.
  vpc_id = aws_vpc.main_vpc.id

  # --- Rotta per il Traffico Internet (IPv4) ---
  # Questa regola instrada tutto il traffico IPv4 in uscita (0.0.0.0/0)
  # verso l'Internet Gateway (IGW), permettendo alle risorse nelle
  # subnet associate di accedere a Internet.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  # --- (Opzionale) Rotta per il Traffico Internet (IPv6) ---
  # Simile alla rotta IPv4, ma per tutto il traffico IPv6 (::/0).
  # Puoi rimuovere questo blocco se la tua VPC non è abilitata per IPv6.
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main_igw.id
  }

  # --- Tag di Metadati per la Risorsa ---
  tags = {
    Name = "${var.aws_region}-public-rt"
  }
}