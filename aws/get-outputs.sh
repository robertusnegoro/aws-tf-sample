#!/bin/bash

# Get the Transit Gateway ID
echo "AWS Transit Gateway ID:"
terraform output aws_transit_gateway_id

# Get the Direct Connect Connection ID
echo -e "\nAWS Direct Connect Connection ID:"
terraform output aws_direct_connect_connection_id

# Get the VPC ID
echo -e "\nAWS VPC ID:"
terraform output aws_vpc_id

# Get the Subnet IDs
echo -e "\nAWS Subnet IDs:"
terraform output aws_subnet_ids 