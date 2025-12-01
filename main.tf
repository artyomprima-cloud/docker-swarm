terraform {
  backend "s3" {
    bucket  = "tfstate-654654568071"
    key     = "terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
