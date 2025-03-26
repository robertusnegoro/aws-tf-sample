# Troubleshooting Notes

## 1. Debugging Kubernetes Pod Issues

### Pod Crash Investigation
1. Check pod status and logs:
   ```bash
   kubectl get pods
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   kubectl logs <pod-name> --previous  # Previous container logs if pod restarted
   ```

2. Check container events:
   ```bash
   kubectl get events --sort-by='.lastTimestamp'
   ```

3. Check resource usage:
   ```bash
   kubectl top pod <pod-name>
   kubectl top node
   ```

### Out of Memory (OOM) Investigation
1. Check memory limits and requests:
   ```bash
   kubectl describe pod <pod-name> | grep -A 5 Resources
   ```

2. Check container metrics:
   ```bash
   kubectl exec -it <pod-name> -- top
   kubectl exec -it <pod-name> -- free -m
   ```

3. Check respective pod log and find for the OOM clue there. 
4. If we have APM, that would be more clear to see the issue from there. 
5. Add another profiling setup to get deeper knowledge about what causing the OOM. 

## 2. Cross-Cloud VM Communication

### GCP VM to AWS EKS Communication
1. Network Path:
   - GCP VM → GCP VPC → Cloud Interconnect → Direct Connect → AWS VPC → EKS

2. Required Components:
   - GCP Cloud Interconnect configured
   - AWS Direct Connect connection
   - Transit Gateway in AWS
   - Proper routing tables in both clouds
   - Security groups and firewall rules

3. Detailed Setup Steps:

   a. AWS EKS Service Exposure:
   ```yaml
   # eks-service.yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: my-service
     annotations:
       service.beta.kubernetes.io/aws-load-balancer-type: nlb
       service.beta.kubernetes.io/aws-load-balancer-internal: "true"
       service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
   spec:
     type: LoadBalancer
     ports:
       - port: 80
         targetPort: 8080
     selector:
       app: my-app
   ```

   b. AWS Security Group Rules:
   ```hcl
   # Allow inbound from GCP VPC CIDR
   resource "aws_security_group_rule" "eks_inbound" {
     type                     = "ingress"
     from_port               = 80
     to_port                 = 80
     protocol                = "tcp"
     cidr_blocks             = ["10.1.0.0/16"]  # GCP VPC CIDR
     security_group_id       = aws_security_group.eks.id
     description            = "Allow inbound from GCP VPC"
   }
   ```

   c. GCP Firewall Rules:
   ```hcl
   # Allow outbound to AWS VPC CIDR
   resource "google_compute_firewall" "allow_aws" {
     name    = "allow-aws-outbound"
     network = google_compute_network.vpc.name
     
     allow {
       protocol = "tcp"
       ports    = ["80"]
     }
     
     source_ranges = ["10.0.0.0/16"]  # GCP VPC CIDR
     target_tags   = ["aws-access"]
   }
   ```

   d. AWS Route Table:
   ```hcl
   resource "aws_route" "gcp" {
     route_table_id         = aws_route_table.private.id
     destination_cidr_block = "10.1.0.0/16"  # GCP VPC CIDR
     transit_gateway_id     = aws_ec2_transit_gateway.main.id
   }
   ```

   e. GCP Route:
   ```hcl
   resource "google_compute_route" "aws" {
     name        = "aws-route"
     network     = google_compute_network.vpc.name
     dest_range  = "10.0.0.0/16"  # AWS VPC CIDR
     priority    = 1000
     next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id
   }
   ```

4. Testing Connectivity:
   ```bash
   # From GCP VM
   # Get EKS service endpoint
   kubectl get svc my-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
   
   # Test connectivity
   curl -v <eks-service-endpoint>
   telnet <eks-service-endpoint> 80
   traceroute <eks-service-endpoint>
   ```

### AWS EC2 to GCP GKE Communication
1. Network Path:
   - AWS EC2 → AWS VPC → Direct Connect → Cloud Interconnect → GCP VPC → GKE

2. Required Components:
   - AWS Direct Connect connection
   - GCP Cloud Interconnect configured
   - Proper routing tables in both clouds
   - Security groups and firewall rules

3. Detailed Setup Steps:

   a. GCP GKE Service Exposure:
   ```yaml
   # gke-service.yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: my-service
     annotations:
       cloud.google.com/load-balancer-type: "Internal"
   spec:
     type: LoadBalancer
     loadBalancerIP: "10.1.0.10"  # Static internal IP
     ports:
       - port: 80
         targetPort: 8080
     selector:
       app: my-app
   ```

   b. GCP Firewall Rules:
   ```hcl
   # Allow inbound from AWS VPC CIDR
   resource "google_compute_firewall" "allow_aws_inbound" {
     name    = "allow-aws-inbound"
     network = google_compute_network.vpc.name
     
     allow {
       protocol = "tcp"
       ports    = ["80"]
     }
     
     source_ranges = ["10.0.0.0/16"]  # AWS VPC CIDR
     target_tags   = ["gke-nodes"]
   }
   ```

   c. AWS Security Group Rules:
   ```hcl
   # Allow outbound to GCP VPC CIDR
   resource "aws_security_group_rule" "ec2_outbound" {
     type                     = "egress"
     from_port               = 80
     to_port                 = 80
     protocol                = "tcp"
     cidr_blocks             = ["10.1.0.0/16"]  # GCP VPC CIDR
     security_group_id       = aws_security_group.ec2.id
     description            = "Allow outbound to GCP VPC"
   }
   ```

   d. GCP Route:
   ```hcl
   resource "google_compute_route" "aws" {
     name        = "aws-route"
     network     = google_compute_network.vpc.name
     dest_range  = "10.0.0.0/16"  # AWS VPC CIDR
     priority    = 1000
     next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id
   }
   ```

   e. AWS Route Table:
   ```hcl
   resource "aws_route" "gcp" {
     route_table_id         = aws_route_table.private.id
     destination_cidr_block = "10.1.0.0/16"  # GCP VPC CIDR
     transit_gateway_id     = aws_ec2_transit_gateway.main.id
   }
   ```

4. Testing Connectivity:
   ```bash
   # From AWS EC2
   # Get GKE service endpoint
   kubectl get svc my-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   
   # Test connectivity
   curl -v <gke-service-endpoint>
   telnet <gke-service-endpoint> 80
   traceroute <gke-service-endpoint>
   ```

### Important Notes:
1. IP Ranges:
   - Ensure VPC CIDR ranges don't overlap
   - AWS VPC: 10.0.0.0/16
   - GCP VPC: 10.1.0.0/16
   - Transit Gateway: 10.2.0.0/16

2. Security Considerations:
   - Use internal load balancers when possible
   - Implement proper authentication/authorization
   - Consider using private endpoints
   - Monitor and log all cross-cloud traffic

3. Performance Optimization:
   - Use appropriate instance types
   - Consider using Cloud NAT for outbound traffic
   - Monitor latency and bandwidth usage
   - Use appropriate MTU settings

## 3. Cross-Cloud Network Troubleshooting

### Network Path Verification
1. Check Cloud Interconnect Status:
   ```bash
   # GCP
   gcloud compute interconnects describe <interconnect-name>
   
   # AWS
   aws directconnect describe-connections --connection-id <connection-id>
   ```

2. Check Routing Tables:
   ```bash
   # GCP
   gcloud compute routes list
   
   # AWS
   aws ec2 describe-route-tables
   ```

3. Check BGP Sessions:
   ```bash
   # GCP
   gcloud compute interconnects get-diagnostics <interconnect-name>
   
   # AWS
   aws directconnect describe-virtual-interfaces
   ```

### Common Issues and Solutions
1. BGP Session Issues:
   - Verify ASN numbers match
   - Check BGP authentication
   - Verify IP addressing

2. Routing Issues:
   - Check route propagation
   - Verify CIDR ranges don't overlap
   - Check security group/firewall rules

3. Latency Issues:
   - Use traceroute to identify bottlenecks
   - Check MTU settings
   - Verify bandwidth allocation

### Monitoring Tools
1. CloudWatch Metrics:
   - Monitor Direct Connect metrics
   - Check for packet loss
   - Monitor bandwidth utilization

2. Stackdriver Monitoring:
   - Monitor Cloud Interconnect health
   - Check for packet loss
   - Monitor bandwidth utilization

3. Network Performance Testing:
   ```bash
   # Install iperf3
   sudo apt-get install iperf3
   
   # Start server
   iperf3 -s
   
   # Test from client
   iperf3 -c <server-ip>
   ``` 