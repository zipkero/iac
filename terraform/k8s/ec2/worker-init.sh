#!/bin/bash
echo "Scanning for and disabling conflicting sysctl settings..."
CONFLICTING_KEYS=(
    'net.ipv4.conf.all.rp_filter'
    'net.ipv4.conf.all.accept_source_route'
    'net.ipv4.conf.all.promote_secondaries'
)

for key in "${CONFLICTING_KEYS[@]}"; do
    # 정규식으로 변환 (dot을 이스케이프)
    key_regex=$(echo "$key" | sed 's/\./\\./g')

    # 설정 파일을 찾아서 해당 라인을 주석 처리
    grep -rl "$key" /etc/sysctl.d/ /usr/lib/sysctl.d/ /etc/sysctl.conf | while read -r file; do
        echo "--> Commenting out '$key' in file: $file"
        # .bak 확장자로 백업 파일을 만들고, 해당 라인 맨 앞에 '#'을 추가
        sed -i.bak -E "s/^\s*$key_regex\s*=.*$/#&/" "$file"
    done
done
echo "Scan complete."

yum update -y --allowerasing

yum install -y yum-utils device-mapper-persistent-data lvm2

yum install -y docker
systemctl start docker
systemctl enable docker

usermod -a -G docker ec2-user

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
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

yum install -y git wget

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