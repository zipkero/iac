data "aws_eip" "sample_eip" {
  id = "eipalloc-0cb747b5bfcb77aa8"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.sample_instance.id
  allocation_id = data.aws_eip.sample_eip.id
}

resource "aws_instance" "sample_instance" {
  ami             = "ami-0f3a440bbcff3d043"  
  instance_type   = "t2.medium"    
  depends_on      = [aws_security_group.sample_sg]
  subnet_id       = aws_subnet.sample_subnet_1.id
  vpc_security_group_ids = [aws_security_group.sample_sg.id]
  
  iam_instance_profile = data.aws_iam_instance_profile.sample_ec2_profile.name

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 50 # 50GB
    delete_on_termination = true
  }

  tags = {
    Name = "sample_instance"
  }

  user_data = <<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
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

cat <<'EOF2' > /usr/local/sample/metricbeat.yml
metricbeat.modules:
- module: docker
  metricsets:
    - container
    - cpu
    - diskio
    - healthcheck
    - info
    - memory
    - network
  hosts: ["unix:///var/run/docker.sock"]
  period: 10s

output.elasticsearch:
  hosts: ["172.20.0.9:9200"]
EOF2

cat <<'EOF2' > /usr/local/sample/filebeat.docker.yml
filebeat.inputs:
  - type: container
    paths:
      - /var/lib/docker/containers/*/*.log
    processors:
      - add_docker_metadata: ~
      - decode_json_fields:
          fields: ["message"]
          target: ""

output.elasticsearch:
  hosts: ["172.20.0.9:9200"]

setup.kibana:
  host: "172.20.0.10:9100"
EOF2

cat <<'EOF2' > /usr/local/sample/docker-compose.yml
version: "3.8"
networks:
  sample_network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
services:
  backoffice:
    depends_on:
      - mysql
      - redis
    image: backoffice:latest
    ports:
      - "5600:5600"    
    networks:
      sample_network:
        ipv4_address: 172.20.0.2
  server:
    depends_on:
      - mysql
      - redis
    image: server:latest
    ports:
      - "2222:2222"
      - "5502:5502"
      - "5503:5503"      
      - "5601:5601"
      - "5602:5602"    
    networks:
      sample_network:
        ipv4_address: 172.20.0.3
  mysql:
    image: mysql:8.2.0
    environment:
      MYSQL_DATABASE: BackOffice
      MYSQL_USER: Server
      MYSQL_PASSWORD: 1234
      MYSQL_ROOT_PASSWORD: 1234
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      sample_network:
        ipv4_address: 172.20.0.4
  redis:
    image: redis:7.2.4-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      sample_network:
        ipv4_address: 172.20.0.5    
volumes:
  mysql-data:
  redis-data:  
EOF2
  EOF
}