resource "aws_vpc" "vpc" {
  lifecycle {
    prevent_destroy = false
  }
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.tags,
    map(
      "Name", var.environment
    )
  )
}

resource "aws_internet_gateway" "igw" {
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-igw"
    )
  )
}

resource "aws_eip" "nat" {
  lifecycle { prevent_destroy = false }
  count = length(var.azs)
  vpc   = true
  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-${var.azs[count.index]}-eip"
    )
  )
}

resource "aws_nat_gateway" "nat_gw" {
  lifecycle { prevent_destroy = false }
  count         = length(var.azs)
  depends_on    = [aws_internet_gateway.igw, aws_eip.nat]
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.external.*.id, count.index)
  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-${var.azs[count.index]}-nat"
    )
  )
}
