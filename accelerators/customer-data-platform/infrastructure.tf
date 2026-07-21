# VPC Module
resource "aws_vpc" "cdp_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "cdp-vpc-${var.environment}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "cdp_igw" {
  vpc_id = aws_vpc.cdp_vpc.id

  tags = {
    Name        = "cdp-igw-${var.environment}"
    Environment = var.environment
  }
}

# EKS Cluster
resource "aws_eks_cluster" "cdp_cluster" {
  name     = "cdp-cluster-${var.environment}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.28"

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "cdp_nodes" {
  cluster_name    = aws_eks_cluster.cdp_cluster.name
  node_group_name = "cdp-nodes-${var.environment}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy
  ]
}

# Kafka MSK Cluster
resource "aws_msk_cluster" "cdp_kafka" {
  cluster_name           = "cdp-kafka-${var.environment}"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 3
  per_broker_storage_info {
    volume_size = 100
  }

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    security_groups = [aws_security_group.kafka_sg.id]
    subnets         = aws_subnet.private[*].id
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.cdp_kms.arn
  }
}

# S3 Data Lake Bucket
resource "aws_s3_bucket" "data_lake" {
  bucket = "cdp-datalake-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "cdp-datalake-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "data_lake_versioning" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM Roles
resource "aws_iam_role" "eks_cluster_role" {
  name = "cdp-eks-cluster-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_role" {
  name = "cdp-eks-node-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

# KMS Key for encryption
resource "aws_kms_key" "cdp_kms" {
  description = "KMS key for CDP data encryption"
  tags = {
    Name        = "cdp-kms-${var.environment}"
    Environment = var.environment
  }
}

# Security Groups
resource "aws_security_group" "kafka_sg" {
  name        = "cdp-kafka-sg-${var.environment}"
  description = "Security group for MSK Kafka cluster"
  vpc_id      = aws_vpc.cdp_vpc.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.cdp_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cdp-kafka-sg-${var.environment}"
    Environment = var.environment
  }
}

# Variables
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "environment" {
  default     = "dev"
  description = "Environment name"
}

# Data sources
data "aws_caller_identity" "current" {}
