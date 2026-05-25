data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true 

  tags = { Name = "eks-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "eks-igw" }
}

# Consolidated Route Table for all subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "eks-public-rt" }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 10}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  
  # CRITICAL: Nodes must have public IPs to reach the internet without a NAT Gateway
  map_public_ip_on_launch = true

  tags = {
    Name                                = "eks-public-${count.index}"
    "kubernetes.io/role/elb"            = "1" 
    "kubernetes.io/role/internal-elb"   = "1" # Added so internal ALBs also work here
    "karpenter.sh/discovery"            = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "endpoints" {
  name        = "vpc-endpoints-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

locals {
  services = ["ec2", "ecr.api", "ecr.dkr", "sts", "logs", "eks", "autoscaling", "ssm", "ssmmessages", "ec2messages", "sqs"]
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = toset(local.services)
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.public[*].id
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public.id] 
}

# =================================================================
# ARCHITECTURAL NOTE FOR RECRUITERS:
# The following resources represent the "Production Standard" 
# architecture (Private Subnets + NAT Gateway). 
# They are currently commented out to optimize for cost 
# in a development environment, using Public Subnets for nodes instead.
# =================================================================

# resource "aws_eip" "nat" {
#   domain = "vpc"
#   tags   = { Name = "eks-nat-eip" }
# }

# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[0].id
#   tags          = { Name = "eks-nat-gw" }
#   depends_on    = [aws_internet_gateway.igw]
# }

# resource "aws_route" "private_nat_gateway" {
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.main.id
# }