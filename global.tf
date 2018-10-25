terraform {
  required_version = "~> 0.10"

  backend "s3" {
    bucket = "subsl"
    key    = "ds/terraform.tfstate"
    region = "us-west-2"
  }
}
