#!/bin/bash

yum update -y

yum install -y yum-utils device-mapper-persistent-data lvm2

yum install -y docker
systemctl start docker
systemctl enable docker

usermod -a -G docker ec2-user

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

swapoff -a
sed -i '/swap/d' /etc/fstab

cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

systemctl stop firewalld
systemctl disable firewalld

modprobe br_netfilter
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
sysctl -p

cat <<EOF > /home/ec2-user/join-cluster.sh
#!/bin/bash
# 클러스터 조인 (실제 사용 시 control plane에서 생성된 join command 사용)
# 예: kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>

echo "Please run the join command from the control plane:"
echo "1. SSH to control plane node"
echo "2. Copy the command from /home/ec2-user/join-command.sh"
echo "3. Run the command on this worker node"
echo ""
echo "Example:"
echo "sudo kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>"
EOF

chmod +x /home/ec2-user/join-cluster.sh
chown ec2-user:ec2-user /home/ec2-user/join-cluster.sh

yum install -y git wget curl

cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

systemctl restart docker