# Security group for Atlantis
resource "aws_security_group" "atlantis" {
  name        = "${var.environment}-atlantis-sg"
  description = "Security group for Atlantis server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 4141
    to_port     = 4141
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Atlantis web interface"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-atlantis-sg"
    Environment = var.environment
  }
}

# IAM role for Atlantis
resource "aws_iam_role" "atlantis" {
  name = "${var.environment}-atlantis-role"

  assume_role_policy = jsonencode({
    Version = "2025-03-26"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-atlantis-role"
    Environment = var.environment
  }
}

# IAM instance profile for Atlantis
resource "aws_iam_instance_profile" "atlantis" {
  name = "${var.environment}-atlantis-profile"
  role = aws_iam_role.atlantis.name
}

# IAM policy for Atlantis
resource "aws_iam_role_policy" "atlantis" {
  name = "${var.environment}-atlantis-policy"
  role = aws_iam_role.atlantis.id

  policy = jsonencode({
    Version = "2025-03-25"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.aws_account_id}-terraform-state",
          "arn:aws:s3:::${var.aws_account_id}-terraform-state/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:${var.aws_region}:*:table/${var.aws_account_id}-terraform-locks"
      }
    ]
  })
}

# EC2 instance for Atlantis
resource "aws_instance" "atlantis" {
  ami           = "ami-0c7217cdde317cfec"  # Change this to ami for Ubuntu 24.04 LTS in ap-southeast-3
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public[0].id  # Using first public subnet

  vpc_security_group_ids = [aws_security_group.atlantis.id]
  iam_instance_profile   = aws_iam_instance_profile.atlantis.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              
              # Update package list
              apt-get update
              
              # Install prerequisites
              apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release
              
              # Add Docker's official GPG key
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              chmod a+r /etc/apt/keyrings/docker.gpg
              
              # Set up the Docker repository
              echo \
                "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                tee /etc/apt/sources.list.d/docker.list > /dev/null
              
              # Update package list again
              apt-get update
              
              # Install Docker Engine
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              
              # Start and enable Docker service
              systemctl start docker
              systemctl enable docker
              
              # Create Atlantis configuration directory
              mkdir -p /opt/atlantis/config
              
              # Create docker-compose.yml
              cat > /opt/atlantis/docker-compose.yml << 'EOL'
              version: '3'
              services:
                atlantis:
                  image: runatlantis/atlantis:latest
                  ports:
                    - "4141:4141"
                  environment:
                    - ATLANTIS_GITLAB_TOKEN=${var.gitlab_token}
                    - ATLANTIS_GITLAB_WEBHOOK_SECRET=${var.gitlab_webhook_secret}
                    - ATLANTIS_GITLAB_BASE_URL=${var.gitlab_base_url}
                    - ATLANTIS_REPO_ALLOWLIST=gitlab.com/random-company-io/*
                    - ATLANTIS_ATLANTIS_URL=https://${aws_instance.atlantis.public_ip}:4141
                    - ATLANTIS_PORT=4141
                    - ATLANTIS_SSL_CERT_FILE=/etc/atlantis/cert.pem
                    - ATLANTIS_SSL_KEY_FILE=/etc/atlantis/key.pem
                  volumes:
                    - /opt/atlantis/config:/etc/atlantis
                  command: server --config /etc/atlantis/config.yaml
              EOL

              # Create Atlantis config file
              cat > /opt/atlantis/config/config.yaml << 'EOL'
              repos:
                - id: /.*/
                  apply_requirements: ["approved", "mergeable"]
                  allowed_overrides: ["apply_requirements", "workflow"]
                  checkout_strategy: merge
                  check_strategy: merge
                  gitlab:
                    token: ${var.gitlab_token}
                    webhook_secret: ${var.gitlab_webhook_secret}
                    base_url: ${var.gitlab_base_url}
              EOL

              # Start Atlantis
              cd /opt/atlantis
              docker compose up -d
              EOF

  tags = {
    Name        = "${var.environment}-atlantis"
    Environment = var.environment
  }
}

# Output the Atlantis URL
output "atlantis_url" {
  description = "URL of the Atlantis server"
  value       = "https://${aws_instance.atlantis.public_ip}:4141"
} 