resource "aws_kms_key" "vault" {
  description         = "Vault auto-unseal key"
  enable_key_rotation = true
  deletion_window_in_days = 10
}
