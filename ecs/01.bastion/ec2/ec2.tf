# 점프서버 EC2 인스턴스 생성
resource "aws_instance" "sample_bastion_instance" {
  ami                         = "ami-00c79d83cf718a893"
  instance_type               = "t2.micro"
  key_name                    = "sample_${var.prefix}_keypair"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.bastion_sg_id]
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y iptables-services

sudo sysctl -w net.ipv4.ip_forward=1
sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'

sudo iptables -t nat -A PREROUTING -p tcp --dport 10201 -j REDIRECT --to-port 22
# sudo iptables -A FORWARD -p tcp -d 127.0.0.1 --dport 22 -j ACCEPT

sudo service iptables save

sudo systemctl enable iptables
sudo systemctl start iptables

%{ for key in var.ssh_keys ~}
echo '${key}' | tee -a /home/ec2-user/.ssh/authorized_keys
%{ endfor ~}

sudo yum install redis6 -y
EOF
  )

  tags = {
    Name = "sample_${var.prefix}_bastion_instance"
  }
}