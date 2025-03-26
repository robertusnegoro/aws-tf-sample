output "aws_transit_gateway_id" {
  description = "ID of the AWS Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "aws_direct_connect_connection_id" {
  description = "ID of the AWS Direct Connect connection"
  value       = aws_dx_connection.onprem.id
}

output "aws_vpc_id" {
  description = "ID of the AWS VPC"
  value       = aws_vpc.main.id
}

output "aws_subnet_ids" {
  description = "IDs of the AWS Subnets"
  value       = aws_subnet.main[*].id
} 