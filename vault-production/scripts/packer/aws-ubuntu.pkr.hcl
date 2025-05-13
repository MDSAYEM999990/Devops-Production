packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
variable "app_name" {
  type = string
  default = "learn-packer-linux-aws-2"

}

variable "environment" {
  type = string
  default ="test"
}
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  
}

source "amazon-ebs" "ubuntu" {
  ami_name      =  "${var.app_name}-${var.environment}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  /* provisioner "shell" {
  inline = [
    "set -e",

    # Update & security patches
    "sudo apt-get update -y && sudo apt-get upgrade -y",
    "sudo apt-get install -y unattended-upgrades fail2ban ufw curl wget gnupg2 software-properties-common zip unzip rsyslog logrotate htop",

    # Set timezone
    "sudo timedatectl set-timezone UTC",

    # Setup UFW firewall
    "sudo ufw allow OpenSSH",
    "sudo ufw allow 8200/tcp",                          # Vault port
    "sudo ufw --force enable",

    # Fail2ban setup
    "sudo systemctl enable fail2ban",
    "sudo systemctl start fail2ban",

    # Add Vault binary
    "VAULT_VERSION=1.15.4",
    "wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip",
    "unzip vault_${VAULT_VERSION}_linux_amd64.zip",
    "sudo mv vault /usr/local/bin/",
    "sudo chmod +x /usr/local/bin/vault",
    "vault -autocomplete-install",
    "complete -C /usr/local/bin/vault vault",

    # Create Vault user
    "sudo useradd --system --home /etc/vault.d --shell /bin/false vault",
    "sudo mkdir -p /etc/vault.d /var/lib/vault /opt/vault/tls",
    "sudo chown -R vault:vault /etc/vault.d /var/lib/vault /opt/vault",

    # TLS Self-Signed Cert (for demo; in production, use ACM/Let's Encrypt or your CA)
    "openssl req -new -x509 -nodes -days 365 -subj \"/CN=vault.local\" -out /opt/vault/tls/vault.crt -keyout /opt/vault/tls/vault.key",
    "chmod 600 /opt/vault/tls/vault.key",
    "chown vault:vault /opt/vault/tls/vault.*",

    # Vault config file (minimal)
    \"cat <<EOF | sudo tee /etc/vault.d/vault.hcl
ui = true
listener \"tcp\" {
  address     = \"0.0.0.0:8200\"
  tls_cert_file = \"/opt/vault/tls/vault.crt\"
  tls_key_file  = \"/opt/vault/tls/vault.key\"
}
storage \"file\" {
  path = \"/var/lib/vault\"
}
disable_mlock = true
EOF
    \",

    # Vault systemd service
    \"cat <<EOF | sudo tee /etc/systemd/system/vault.service
[Unit]
Description=Vault service
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
    \",

    # Enable & start Vault
    "sudo systemctl daemon-reexec",
    "sudo systemctl daemon-reload",
    "sudo systemctl enable vault",
    "sudo systemctl start vault",

    # Enable rsyslog and logrotate
    "sudo systemctl enable rsyslog && sudo systemctl start rsyslog",

    # Clean up
    "rm -f vault_${VAULT_VERSION}_linux_amd64.zip"
  ]
}*/

}
