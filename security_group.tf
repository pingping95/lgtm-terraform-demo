# Security Group for EKS Node
resource "aws_security_group" "eks_node" {
  name        = "${var.prefix}-node-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for EKS nodes managed by Karpenter"

  tags = {
    "karpenter.sh/discovery" = var.prefix
    Name                     = "${var.prefix}-node-sg"
    Environment             = var.environment
  }
}

# Security Group Rules for Node Group
resource "aws_security_group_rule" "node_vpc_ingress" {
  security_group_id = aws_security_group.eks_node.id
  type              = "ingress"
  description       = "Allow inbound traffic from VPC CIDR"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [module.vpc.vpc_cidr_block]
}

resource "aws_security_group_rule" "node_primary_ingress" {
  security_group_id        = aws_security_group.eks_node.id
  type                     = "ingress"
  description             = "Allow inbound traffic from primary cluster security group"
  from_port               = 0
  to_port                 = 0
  protocol                = -1
  source_security_group_id = module.eks.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "node_cluster_ingress" {
  security_group_id        = aws_security_group.eks_node.id
  type                     = "ingress"
  description             = "Allow inbound traffic from cluster security group"
  from_port               = 0
  to_port                 = 0
  protocol                = -1
  source_security_group_id = module.eks.cluster_security_group_id
}

resource "aws_security_group_rule" "node_egress" {
  security_group_id = aws_security_group.eks_node.id
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

# Outputs
output "eks_cluster_sg_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_primary_sg_id" {
  description = "EKS cluster primary security group ID"
  value       = module.eks.cluster_primary_security_group_id
}