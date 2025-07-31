# =============================================================================
# LAUNCH TEMPLATE
# =============================================================================
# Definisce il modello di configurazione per le istanze EC2 che verranno
# lanciate dall'Auto Scaling Group. Specifica l'AMI, il tipo di istanza,
# i permessi, la sicurezza e lo script di avvio.

resource "aws_launch_template" "main_lt" {
  name_prefix   = "${var.asg_name}-lt-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  # Associa il profilo IAM per dare alle istanze i permessi necessari.
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  # Associa i security group alle interfacce di rete delle istanze.
  network_interfaces {
    security_groups = [aws_security_group.web_sg.id]
  }

  # Script di avvio semplificato: installa solo Docker.
  # Non tenta di avviare l'applicazione.
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Script per l'installazione di Docker su Amazon Linux 2023

    echo "--- Inizio aggiornamento dei pacchetti di sistema ---"
    sudo dnf update -y
    echo "--- Aggiornamento dei pacchetti completato ---"

    echo "--- Inizio installazione di Docker ---"
    sudo dnf install docker -y
    echo "--- Installazione di Docker completata ---"

    echo "--- Avvio e abilitazione del servizio Docker ---"
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "--- Servizio Docker attivo e abilitato ---"

    echo "--- Aggiunta dell'utente 'ec2-user' al gruppo 'docker' ---"
    sudo usermod -aG docker ec2-user
    echo "--- Permessi Docker configurati ---"

    echo "--- Script di User Data (solo infrastruttura) completato ---"
    EOF
  )

  # Abilita il monitoraggio dettagliato per le istanze.
  monitoring {
    enabled = true
  }

  tags = {
    Name = "${var.asg_name}-launch-template"
  }
}

# =============================================================================
# AUTO SCALING GROUP (ASG)
# =============================================================================
# Gestisce il ciclo di vita delle istanze EC2, garantendo che il numero
# desiderato di istanze sia sempre in esecuzione. Si occupa anche di
# registrare le nuove istanze nel Target Group dell'ALB.

resource "aws_autoscaling_group" "main_asg" {
  name                 = var.asg_name
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity
  
  # Specifica le subnet pubbliche in cui l'ASG può lanciare le istanze.
  vpc_zone_identifier  = [for subnet in aws_subnet.public : subnet.id]

  # Collega l'ASG al Target Group dell'ALB.
  target_group_arns    = [aws_lb_target_group.app_tg.arn]

  # Usa il Launch Template definito sopra per creare nuove istanze.
  launch_template {
    id      = aws_launch_template.main_lt.id
    version = "$Latest"
  }

  # Usa gli health check dell'ALB per determinare lo stato delle istanze.
  health_check_type         = "ELB"
  health_check_grace_period = 300 # Tempo (in sec) prima di iniziare gli health check

  # Applica i tag a tutte le istanze lanciate dall'ASG.
  tag {
    key                 = "Name"
    value               = "${var.asg_name}-instance"
    propagate_at_launch = true
  }
}
