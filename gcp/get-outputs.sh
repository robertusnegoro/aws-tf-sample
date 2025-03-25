#!/bin/bash

# Get the Cloud Interconnect Attachment ID
echo "GCP Cloud Interconnect Attachment ID:"
terraform output gcp_cloud_interconnect_attachment_id

# Get the Router ID
echo -e "\nGCP Router ID:"
terraform output gcp_router_id

# Get the Network ID
echo -e "\nGCP Network ID:"
terraform output gcp_network_id

# Get the Subnet ID
echo -e "\nGCP Subnet ID:"
terraform output gcp_subnet_id 