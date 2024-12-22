region_name = "ap-northeast-2"
environment = "dev"
allow_ip    = ["39.117.40.3", "182.228.179.171"]
prefix      = "my-lgtm-test"

vpc = {
  cidr            = "10.10.0.0/16"
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets  = ["10.10.0.0/22", "10.10.4.0/22"]
  private_subnets = ["10.10.100.0/22", "10.10.104.0/22"]
}

eks = {
  version         = "1.31"
  init_node_name  = "init-node"
  init_node_count = 1
  shared_prefix   = "eks-cluster-node-shared"
}

rds = {
  engine                      = "mariadb"
  engine_version              = "10.6"
  instance_class              = "db.t3.medium"
  admin_username              = "admin"
  admin_password              = "passw0rd1!"
  manage_master_user_password = false
  publicly_accessible         = true
  create_db_subnet_group      = true
}