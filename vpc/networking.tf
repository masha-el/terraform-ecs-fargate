resource "aws_subnet" "internal" {
  lifecycle { prevent_destroy = false }
  count             = length(var.azs)
  availability_zone = var.azs[count.index]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, (var.subnet_size - 20), count.index)
  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-internal-${var.azs[count.index]}",
      "type", "internal"
    )
  )
}

resource "aws_subnet" "external" {
  lifecycle { prevent_destroy = false }
  count             = length(var.azs)
  availability_zone = var.azs[count.index]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, (var.subnet_size - 20), count.index + 3)
  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-external-${var.azs[count.index]}",
      "type", "external"
    )
  )
}

resource "aws_subnet" "internal_db" {
  lifecycle { prevent_destroy = false }
  count             = length(var.azs)
  availability_zone = var.azs[count.index]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, (var.subnet_size - 20), count.index + 6)
  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-db-internal-${var.azs[count.index]}",
      "type", "internal_db"
    )
  )
}

resource "aws_route_table" "external" {
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-external"
    )
  )
}

resource "aws_route" "external_igw" {
  route_table_id         = aws_route_table.external.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [aws_route_table.external]
}

resource "aws_vpc_endpoint" "s3" {
  lifecycle { prevent_destroy = false }
  count        = var.create_s3_vpce ? 1 : 0
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"

  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-s3-vpce-internal"
    )
  )
}

locals {
  create_s3_vpce_count = [
    for subnet in var.azs :
    subnet
    if var.create_s3_vpce
  ]
}

resource "aws_vpc_endpoint_route_table_association" "internal" {
  lifecycle { prevent_destroy = false }
  count           = length(local.create_s3_vpce_count)
  route_table_id  = element(aws_route_table.internal.*.id, count.index)
  vpc_endpoint_id = element(aws_vpc_endpoint.s3.*.id, count.index)
}

resource "aws_route_table_association" "external" {
  lifecycle {
    prevent_destroy = false
  }
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.external.*.id, count.index)
  route_table_id = aws_route_table.external.id

}

resource "aws_network_acl" "external_acl" {
  lifecycle { prevent_destroy = false }
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = toset(aws_subnet.external.*.id)

  egress {
    protocol   = "-1"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-External"
    )
  )
}

resource "aws_route_table" "internal" {
  count = length(var.azs)
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-${var.azs[count.index]}-internal"
    )
  )
}

resource "aws_route" "internal_igw" {
  count = length(var.azs)

  route_table_id         = element(aws_route_table.internal.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)

  depends_on = [aws_route_table.internal]
}

resource "aws_route_table_association" "internal" {
  lifecycle { prevent_destroy = false }
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.internal.*.id, count.index)
  route_table_id = element(aws_route_table.internal.*.id, count.index)
}

resource "aws_network_acl" "internal_acl" {
  lifecycle { prevent_destroy = false }
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = concat(aws_subnet.internal.*.id, aws_subnet.internal_db.*.id)

  egress {
    protocol   = "-1"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-Internal"
    )
  )
}

resource "aws_route_table" "db_internal" {
  lifecycle {
    prevent_destroy = false
  }
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    map(
      "Name", "${var.environment}-db-internal"
    )
  )
}

resource "aws_route_table_association" "internal_db" {
  lifecycle { prevent_destroy = false }
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.internal_db.*.id, count.index)
  route_table_id = aws_route_table.db_internal.id
}
