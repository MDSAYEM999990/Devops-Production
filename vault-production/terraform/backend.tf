terraform {
  backend "s3" {
    bucket  = "iaccode9990"
    key     = "vault/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
