terraform {
  backend "s3" {
    bucket         = "kelvin-terraform-state-permanent"
    key            = "bootstrap/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locking-permanent"
  }
}