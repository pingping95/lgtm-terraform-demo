# RDS Instance
module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "${var.prefix}-aurora-mysql"

  # Engine Configuration
  engine               = var.rds.engine
  engine_version      = var.rds.engine_version
  instance_class      = var.rds.instance_class
  allocated_storage   = 40
  family              = "${var.rds.engine}${var.rds.admin_password}"  # TODO: Change this appropriately
  major_engine_version = var.rds.engine_version

  # Authentication
  username                            = var.rds.admin_username
  manage_master_user_password         = var.rds.manage_master_user_password
  password                           = var.rds.admin_password
  iam_database_authentication_enabled = false

  # Network Configuration
  publicly_accessible     = var.rds.publicly_accessible
  create_db_subnet_group = var.rds.create_db_subnet_group
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_ids             = module.vpc.public_subnets

  # Upgrade Settings
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  deletion_protection        = true

  tags = {
    Name        = "${var.prefix}-aurora-mysql"
    Environment = var.environment
  }
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "${var.prefix}-db-sg"
  description = "Security group for database instances"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.prefix}-db-sg"
    Environment = var.environment
  }
}

# Security Group Rules
resource "aws_security_group_rule" "db_ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.db_sg.id

  cidr_blocks = concat(
    [module.vpc.vpc_cidr_block],
    [for ip in module.vpc.nat_public_ips : "${ip}/32"],
    [for ip in var.allow_ip : "${ip}/32"]
  )

  description = "Allow inbound database traffic"
}

resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.db_sg.id
  cidr_blocks       = ["0.0.0.0/0"]

  description = "Allow all outbound traffic"
}

# Outputs
output "db_instance_endpoint" {
  description = "The connection endpoint for the database"
  value       = module.db.db_instance_endpoint
}

output "db_instance_id" {
  description = "The ID of the database instance"
  value       = module.db.db_instance_id
}