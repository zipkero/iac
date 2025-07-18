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

yum install -y containerd yum-utils device-mapper-persistent-data lvm2 git wget

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable containerd
systemctl restart containerd

sleep 5

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl
EOF

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

sleep 5

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