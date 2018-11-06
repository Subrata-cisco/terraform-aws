variable region {
  default = "us-west-2"
}

variable "log_bucket_name" {
  default = "subrata-server-logs"
}

variable "s3_key" {
  default = "ds/terraform.tfstate"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cidr_private" {
  default = "10.0.1.0/24"
}

variable "cidr_two" {
  default = "10.0.2.0/24"
}

variable "cidr_three" {
  default = "10.0.3.0/24"
}

variable "az" {
  type = "map"

  default = {
    az1 = "us-west-2a"
    az2 = "us-west-2b"
  }
}

variable "fromAnySourceCIDR" {
  default = "0.0.0.0/0"
}

variable "ubuntu_ami" {
  default = "ami-0bbe6b35405ecebdb"
}

variable "amazon_linux_ami" {
  default = "ami-a0cfeed8"
}

variable "dns_name_for_kms_db" {
  default = "kmsdbdns"
}

/*variable "aws_access_key" {
  description = "AWS access key :"
}
variable "aws_secret_key" {
  description = "AWS secret key :"
}*/

