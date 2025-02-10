terraform {
  backend "s3" {
    bucket = "kube-bucket-tf-new"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }

  required_version = ">= 1.0"

}