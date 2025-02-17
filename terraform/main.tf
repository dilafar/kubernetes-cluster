provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                               = "${var.env_prefix}-vpc"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}


module "subnet" {
  source = "./modules/subnet"

  env_prefix             = var.env_prefix
  availability_zone      = var.availability_zone
  subnet_cidr_block      = var.subnet_cidr_block
  vpc_id                 = aws_vpc.dev-vpc.id
  default_route_table_id = aws_vpc.dev-vpc.default_route_table_id

}


module "webserver" {
  source               = "./modules/webserver"
  vpc_id               = aws_vpc.dev-vpc.id
  my_ip                = var.my_ip
  env_prefix           = var.env_prefix
  ami_name             = var.ami_name
  public_key_location  = var.public_key_location
  instance_type_master = var.instance_type_master
  instance_type_worker = var.instance_type_worker
  availability_zone    = var.availability_zone
  subnet_id            = module.subnet.subnet_id.id
  vpc_cidr_block       = var.vpc_cidr_block

}

module "loadbalancer" {
  source      = "./modules/loadbalancer"
  env_prefix  = var.env_prefix
  vpc_id      = aws_vpc.dev-vpc.id
  subnet_id   = module.subnet.subnet_id.id
  master_1_id = module.webserver.instance_master.id
  master_2_id = module.webserver.instance_master_2.id

}
