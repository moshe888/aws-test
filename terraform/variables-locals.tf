locals {
  common_tags = {
      owner = "Ishay"
      usage = "ColmanProject"
  }
  vpc_name       = "colman-cloud-demo2"
  vpc_cidr_block = "10.10.0.0/16"
  public_subnets = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
  ami = "ami-04535ee68d7419508"
}