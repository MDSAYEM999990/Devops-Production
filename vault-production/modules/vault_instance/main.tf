resource "aws_instance" "vault" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name
  iam_instance_profile   = var.instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              echo "Vault installing..."
              sudo apt update -y
              sudo apt install -y vault
              sudo systemctl enable vault
              sudo systemctl start vault
              EOF

  tags = {
    Name = "vault-server"
  }
}
