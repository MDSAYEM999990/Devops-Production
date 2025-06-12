packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "eks-production-al2023" {
  ami_name      = "eks-production-al2023-{{timestamp}}"
  instance_type = "t3.medium"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  ssh_username = "ec2-user"
}

build {
  name    = "eks-production-al2023"
  sources = ["source.amazon-ebs.eks-production-al2023"]

  provisioner "shell" {
  inline = [
    "sudo yum update -y",
    "sudo yum install -y wget git unzip tar jq vim htop tree bash-completion net-tools bind-utils docker amazon-ssm-agent",

    "sudo systemctl enable docker amazon-ssm-agent",
    "sudo systemctl start docker amazon-ssm-agent",

    "echo -e '[kubernetes]\\nname=Kubernetes\\nbaseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/\\nenabled=1\\ngpgcheck=1\\ngpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key' | sudo tee /etc/yum.repos.d/kubernetes.repo",

    "sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes",
    "sudo systemctl enable kubelet",

    "curl -sSL 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip",
    "unzip awscliv2.zip",
    "sudo ./aws/install",
    "rm -rf aws awscliv2.zip",

    "sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config || true",
    "sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config || true",
    "sudo systemctl restart sshd",

    "sudo setenforce 0 || true",
    "sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config || true",

    "sudo yum clean all"
  ]
}

}
