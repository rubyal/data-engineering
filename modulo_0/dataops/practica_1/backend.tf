# Backend parcial: los valores concretos viven en backend/<ambiente>.hcl,
# de modo que cada ambiente tenga su propio state aislado.
#
#   terraform init -reconfigure -backend-config=backend/dev.hcl
terraform {
  backend "s3" {}
}
