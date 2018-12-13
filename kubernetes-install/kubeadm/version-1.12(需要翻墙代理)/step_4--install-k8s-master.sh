#!/usr/bin/env bash
# made by Caixisheng  Fri Nov 9 CST 2018
# https://www.cnblogs.com/waken-captain/


kubeadm reset
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/
rm -rf /var/lib/etcd/

kubeadm init    --kubernetes-version=v1.12.2   --pod-network-cidr=10.244.0.0/16
#kubeadm init    --kubernetes-version=v1.12.2   --pod-network-cidr=10.244.0.0/16    --apiserver-advertise-address=$(ifconfig  eth0 | grep "inet" | awk '{print $2}')

# To start using your cluster, you need to run the following as a regular user:
mkdir -p /root/.kube
mv -f /etc/kubernetes/admin.conf /root/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "install flannel"
kubectl create -f  ../yaml/flannel/kube-flannel.yml

# 因为是测试环境机器不够，所以去掉 NoSchedule 污点
kubectl taint nodes k8s-master  node-role.kubernetes.io/master-

echo -e "\033[32m查看K8S状态\033[0m"
kubectl get cs
