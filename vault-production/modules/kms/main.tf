resource "aws_kms_key" "vault" {
  description         = "Vault auto-unseal key"
  enable_key_rotation = true
}
