# =============================================================================
# TABELLA DYNAMODB GLOBALE
# =============================================================================
resource "aws_dynamodb_table" "main_table" {
  # Il count previene la creazione della tabella nella regione di DR,
  # poiché verrà creata come replica.
  count        = !var.is_dr_region ? 1 : 0

  name         = "${var.project_name}-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "key"
  range_key    = "uuid"

  attribute {
    name = "key"
    type = "S"
  }
  attribute {
    name = "uuid"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Definisce la replica per la Global Table.
  replica {
    region_name = var.dr_region_name
  }

  tags = {
    Name = "${var.project_name}-data"
  }
}
