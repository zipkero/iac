resource "aws_instance" "dev_control_plane" {
  ami                         = "ami-0e18fe6ecdad223e5"
  instance_type               = "t2.micro"
  key_name                    = "dev_keypair"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.dev_sg_id]
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y iptables-services

sudo sysctl -w net.ipv4.ip_forward=1
sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'

sudo iptables -t nat -A PREROUTING -p tcp --dport 10201 -j REDIRECT --to-port 22
sudo iptables -A FORWARD -p tcp -d 127.0.0.1 --dport 22 -j ACCEPT

sudo service iptables save

sudo systemctl enable iptables
sudo systemctl start iptables
EOF
  )

  tags = {
    Name = "${var.prefix}_control_plane"
  }
}

resource "aws_instance" "dev_data_plane_01" {
  ami                         = "ami-040c33c6a51fd5d96"
  instance_type               = "t2.micro"
  key_name                    = "dev_keypair"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.dev_sg_id]
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y iptables-services

sudo sysctl -w net.ipv4.ip_forward=1
sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'

sudo iptables -t nat -A PREROUTING -p tcp --dport 10201 -j REDIRECT --to-port 22
sudo iptables -A FORWARD -p tcp -d 127.0.0.1 --dport 22 -j ACCEPT

sudo service iptables save

sudo systemctl enable iptables
sudo systemctl start iptables
EOF
  )

  tags = {
    Name = "${var.prefix}_data_plane_01"
  }
}

resource "aws_instance" "dev_data_plane_02" {
  ami                         = "ami-040c33c6a51fd5d96"
  instance_type               = "t2.micro"
  key_name                    = "dev_keypair"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.dev_sg_id]
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y iptables-services

sudo sysctl -w net.ipv4.ip_forward=1
sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'

sudo iptables -t nat -A PREROUTING -p tcp --dport 10201 -j REDIRECT --to-port 22
sudo iptables -A FORWARD -p tcp -d 127.0.0.1 --dport 22 -j ACCEPT

sudo service iptables save

sudo systemctl enable iptables
sudo systemctl start iptables
EOF
  )

  tags = {
    Name = "${var.prefix}_data_plane_02"
  }
}