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

cat <<EOF > /home/ec2-user/init-cluster.sh
#!/bin/bash
# 클러스터 초기화 (실제 사용 시 실행)
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=\$(hostname -I | awk '{print \$1}')

# kubectl 설정 (root 사용자)
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config

# kubectl 설정 (ec2-user 사용자)
mkdir -p /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

# 네트워크 플러그인 설치
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

# 조인 토큰 생성 및 저장
kubeadm token create --print-join-command > /home/ec2-user/join-command.sh
chmod +x /home/ec2-user/join-command.sh
chown ec2-user:ec2-user /home/ec2-user/join-command.sh

echo "Cluster initialized successfully!"
echo "Join command saved to /home/ec2-user/join-command.sh"
EOF

chmod +x /home/ec2-user/init-cluster.sh
chown ec2-user:ec2-user /home/ec2-user/init-cluster.sh

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