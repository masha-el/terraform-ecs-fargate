output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "nat_public_ips" {
  value = aws_eip.nat.*.public_ip
}

output "internal_subnets" {
  value = aws_subnet.internal.*.id
}

output "external_subnets" {
  value = aws_subnet.external.*.id
}

output "db_subnets" {
  value = aws_subnet.internal_db.*.id
}

output "vpce_id" {
  value = "${element(concat(aws_vpc_endpoint.s3.*.id, list("")), 0)}"
}
