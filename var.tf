variable "region_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "allow_ip" {
  type = list(string)
}

variable "prefix" {
  type = string
}

variable "vpc" {
  type = object({
    cidr            = string
    azs             = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}

variable "eks" {
  type = object({
    version         = string
    init_node_name  = string
    init_node_count = number
    shared_prefix   = string
  })
}

variable "rds" {
  type = object({
    engine                      = string
    engine_version              = string
    instance_class              = string
    admin_username              = string
    admin_password              = string
    manage_master_user_password = bool
    publicly_accessible         = bool
    create_db_subnet_group      = bool
  })
}