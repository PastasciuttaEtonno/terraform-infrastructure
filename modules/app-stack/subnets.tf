# =============================================================================
# SUBNET PUBBLICHE
# =============================================================================
# Crea le subnet pubbliche all'interno della VPC. Una subnet viene creata
# per ogni Availability Zone (AZ) definita nella variabile 'subnet_config'
# per la regione selezionata.

resource "aws_subnet" "public" {
  # Itera sulla mappa della regione selezionata (es. var.subnet_config["us-east-1"]).
  # 'each.key' sarà l'AZ (es. "us-east-1a").
  # 'each.value' sarà il blocco CIDR (es. "172.31.0.0/20").
  for_each = var.subnet_config[var.aws_region]

  # Associazione alla VPC e configurazione di rete.
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value
  availability_zone = each.key

  # Imposta a 'true' per assegnare automaticamente un indirizzo IP pubblico
  # a qualsiasi istanza lanciata in questa subnet.
  map_public_ip_on_launch = true

  # Tag di metadati per identificare la subnet.
  tags = {
    Name = "${var.aws_region}-${each.key}-public-subnet"
  }
}

# =============================================================================
# ASSOCIAZIONE TABELLA DI ROTTA
# =============================================================================
# Associa ogni subnet pubblica creata sopra alla tabella di rotta pubblica.
# Questo passaggio è fondamentale per garantire che le subnet abbiano una rotta
# verso l'Internet Gateway e possano quindi comunicare con Internet.

resource "aws_route_table_association" "public_subnet_association" {
  # Itera su ogni subnet creata dalla risorsa 'aws_subnet.public'.
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}