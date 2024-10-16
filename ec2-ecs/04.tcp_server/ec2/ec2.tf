resource "aws_service_discovery_private_dns_namespace" "sample_private_dns_namespace" {
  name        = "sample.${var.prefix}.internal"
  description = "sample private dns namespace"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "sample_discovery_tcp_server_service" {
  name         = "tcp-server"
  namespace_id = aws_service_discovery_private_dns_namespace.sample_private_dns_namespace.id
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.sample_private_dns_namespace.id
    routing_policy = "MULTIVALUE"
    dns_records {
      type = "A"
      ttl  = 60
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_instance" "sample_tcp_server_instance" {
  ami = "ami-0ac6b9b2908f3e20d"
  instance_type = "t3.medium"
  # instance_type = "c6a.xlarge"
  key_name  = "sample_prod_keypair"
  subnet_id = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.tcp_server_sg_id]

  user_data = <<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

apt-get update
apt-get install -y awscli

%{ for key in var.ssh_keys ~}
echo '${key}' | tee -a /home/ubuntu/.ssh/authorized_keys
%{ endfor ~}

mkdir -p /usr/local/sample

cat <<'EOF2' > /usr/local/sample/docker-compose.yml
networks:
  sample_network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
services:
  tcp_master:
    image: 296519485637.dkr.ecr.ap-northeast-2.amazonaws.com/sample_server_test_repo:latest
    ports:
      - "5601:5601"
    restart: unless-stopped
    networks:
      sample_network:
        ipv4_address: 172.20.0.2
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "5601"]
      interval: 1m
      timeout: 10s
      retries: 3
      start_period: 10s
    environment:
      ENABLE_GAME_SERVER: "false"
      ENABLE_REPORT_SERVER: "false"
      ENABLE_SOCIAL_MASTER_SERVER: "true"
      ENABLE_SOCIAL_SERVER: "false"
      PORT: "5601"
  tcp_social:
    image: 296519485637.dkr.ecr.ap-northeast-2.amazonaws.com/sample_server_test_repo:latest
    ports:
      - "5602:5602"
    restart: unless-stopped
    networks:
      sample_network:
        ipv4_address: 172.20.0.3
    depends_on:
      - tcp_master
    environment:
      ENABLE_GAME_SERVER: "false"
      ENABLE_REPORT_SERVER: "false"
      ENABLE_SOCIAL_MASTER_SERVER: "false"
      ENABLE_SOCIAL_SERVER: "true"
      PORT: "5602"
EOF2
  EOF

  tags = {
    Name = "sample_${var.prefix}_tcp_server_instance"
  }
}

resource "aws_lb_target_group_attachment" "sample_nlb_tg_attachment_5601" {
  target_group_arn = var.nlb_tg_5601_arn
  target_id        = aws_instance.sample_tcp_server_instance.private_ip
  port             = 5601
}

resource "aws_lb_target_group_attachment" "sample_nlb_tg_attachment_5602" {
  target_group_arn = var.nlb_tg_5602_arn
  target_id        = aws_instance.sample_tcp_server_instance.private_ip
  port             = 5602
}

resource "aws_service_discovery_instance" "sample_tcp_server_instance" {
  instance_id = aws_instance.sample_tcp_server_instance.id
  service_id  = aws_service_discovery_service.sample_discovery_tcp_server_service.id
  attributes = {
    "AWS_INSTANCE_IPV4" = aws_instance.sample_tcp_server_instance.private_ip
  }
}