variable region {
  default = "us-west-2"
}

variable "log_bucket_name" {
  default = "subrata-server-logs"
}

variable "s3_key" {
  default = "ds/terraform.tfstate"
}

variable "cidrblock" {
  default = "10.0.0.0/16"
}

variable "cidrblocksn1" {
  default = "10.0.1.0/24"
}

variable "cidrblocksn2" {
  default = "10.0.2.0/24"
}

variable "az" {
  type = "map"

  default = {
    az1 = "us-west-2a"
    az2 = "us-west-2b"
  }
}