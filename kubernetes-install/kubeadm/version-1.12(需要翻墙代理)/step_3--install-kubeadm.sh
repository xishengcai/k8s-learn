#!/usr/bin/env bash
# made by Caixisheng  Fri Nov 9 CST 2018
# https://www.cnblogs.com/waken-captain/
# 目前安装的是kubernetes 1.12.2版本

#check
[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }


echo "添加kubernetes国内yum源"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF


cat <<EOF >  /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl --system
swapoff -a

echo "执行yum缓存"
yum -y install epel-release
yum clean all
yum makecache

echo "安装kubeadmin"
yum -y  remove kubeadm kubectl kubelet
yum -y install kubelet-1.12.2-0 kubeadm-1.12.2-0 kubectl-1.12.2-0 kubernetes-cni

systemctl enable kubelet && systemctl start kubelet




