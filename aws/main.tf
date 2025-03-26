# AWS VPC for Transit Gateway
resource "aws_vpc" "main" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# AWS Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Transit Gateway for GCP and On-Prem connectivity"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support               = "enable"

  tags = {
    Name = var.aws_transit_gateway_name
  }
}

# AWS Transit Gateway VPC Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = aws_subnet.main[*].id
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.main.id

  tags = {
    Name = "tgw-vpc-attachment"
  }
}

# AWS Subnets
resource "aws_subnet" "main" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 8, count.index)
  availability_zone = var.aws_availability_zones[count.index]

  tags = {
    Name = "subnet-${count.index + 1}"
  }
}

# AWS Direct Connect Connection
resource "aws_dx_connection" "onprem" {
  name            = var.aws_direct_connect_connection_name
  bandwidth       = var.aws_direct_connect_bandwidth
  location        = var.aws_direct_connect_location

  tags = {
    Name = "dx-onprem-connection"
  }
}

# AWS Direct Connect Gateway
resource "aws_dx_gateway" "main" {
  name            = "dx-gateway"
  amazon_side_asn = 64512
}

# AWS Direct Connect Gateway Association
resource "aws_dx_gateway_association" "main" {
  dx_gateway_id         = aws_dx_gateway.main.id
  associated_gateway_id = aws_ec2_transit_gateway.main.id
} 