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
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
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
   provisioner "shell" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y curl unzip gnupg lsb-release",
    "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
    "sudo apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
    "sudo apt-get update",
    "sudo apt-get install -y vault",

    "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
    "unzip awscliv2.zip",
    "sudo ./aws/install",
    "aws --version",

    
    "if ! snap list | grep -q amazon-ssm-agent; then",
    "  echo 'Installing amazon-ssm-agent via snap...';",
    "  sudo snap install amazon-ssm-agent --classic;",
    "else",
    "  echo 'amazon-ssm-agent already installed via snap.';",
    "fi",


  
    "sudo systemctl enable vault",
    "sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service",
    "sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service",

    "curl \"https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb\" -o session-manager-plugin.deb",
    "sudo dpkg -i session-manager-plugin.deb",
    "session-manager-plugin --version",
  ]
}

 
}
