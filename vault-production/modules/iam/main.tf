
resource "aws_iam_role" "vault_role" {
  name = "vault-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "vault_ssm_policy" {
  name        = "VaultSSMPolicy"
  description = "Allow SSM and KMS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:*",
          "ec2messages:*",
          "ssmmessages:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vault_attach" {
  role       = aws_iam_role.vault_role.name
  policy_arn = aws_iam_policy.vault_ssm_policy.arn
}

resource "aws_iam_instance_profile" "vault_profile" {
  name = "vault-instance-profile"
  role = aws_iam_role.vault_role.name
  lifecycle {
    create_before_destroy = true
    ignore_changes = [name]
  }
  depends_on = [ aws_iam_role_policy_attachment.vault_attach ]
}
