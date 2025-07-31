# =============================================================================
# OUTPUT DEL MODULO APP-STACK
# =============================================================================
# Definisce i valori che il modulo espone al chiamante (il main.tf root).

output "alb_dns_name" {
  description = "Il DNS name dell'Application Load Balancer creato in questa regione."
  value       = aws_lb.main_alb.dns_name
}

output "account_id" {
  description = "L'ID dell'account AWS."
  # CORREZIONE: Restituisce il valore della variabile 'account_id' passata
  # in input al modulo, invece di cercare una data source locale.
  value       = var.account_id
}
