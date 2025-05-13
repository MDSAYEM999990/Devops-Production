resource "aws_subnet" "private_subnet_a" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_a_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "vault-private-a"
  }
}
