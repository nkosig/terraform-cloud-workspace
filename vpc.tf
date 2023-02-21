# Configure the AWS provider
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name       = "${var.client}-${var.team}-${var.environment}-${var.region}-vpc"
    CostCenter = var.cost_center
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name       = "${var.client}-${var.team}-${var.environment}-${var.region}-public-subnet-${var.subnet_number}"
    CostCenter = var.cost_center
  }
}

# Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name       = "${var.client}-${var.team}-${var.environment}-${var.region}-internet-gateway"
    CostCenter = var.cost_center
  }
}

# Create route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name       = "${var.client}-${var.team}-${var.environment}-${var.region}-public-route-table"
    CostCenter = var.cost_center
  }
}

# Create default route to internet gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Associate public subnet with route table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate internet gateway with route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name       = "${var.client}-${var.team}-${var.environment}-${var.region}-private-route-table"
    CostCenter = var.cost_center
  }
}
