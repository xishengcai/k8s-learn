#!/bin/bash
# made by Elven , 2018-5-1
# Blog http://www.cnblogs.com/elvi/p/8976305.html
#下载k8s镜像，安装kubeadm工具

#check
[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }

#docker check
docker images &>/dev/null
[[ $? = 0 ]] || { curl -s http://elven.vip/ks/sh/docker.sh |bash ; }
docker images &>/dev/null
[[ $? = 0 ]] && { echo "docker ok"; } || { echo "docker error";exit; }

#安装kubelet kubeadm
curl -s http://elven.vip/ks/sh/kubelet.sh |bash

echo '下载K8S相关镜像'
MyUrl=registry.cn-shanghai.aliyuncs.com/alik8s
images=(kube-proxy-amd64:v1.10.0 kube-controller-manager-amd64:v1.10.0 kube-scheduler-amd64:v1.10.0 kube-apiserver-amd64:v1.10.0 etcd-amd64:3.1.12 kubernetes-dashboard-amd64:v1.8.3 heapster-grafana-amd64:v4.4.3 heapster-influxdb-amd64:v1.3.3 heapster-amd64:v1.4.2 k8s-dns-dnsmasq-nanny-amd64:1.14.8 k8s-dns-sidecar-amd64:1.14.8 k8s-dns-kube-dns-amd64:1.14.8 pause-amd64:3.1)
#
for imageName in ${images[@]} ; do
  docker pull $MyUrl/$imageName
  docker tag $MyUrl/$imageName k8s.gcr.io/$imageName
  docker rmi $MyUrl/$imageName
done
#
docker pull $MyUrl/flannel:v0.10.0-amd64
docker tag $MyUrl/flannel:v0.10.0-amd64  quay.io/coreos/flannel:v0.10.0-amd64
docker rmi $MyUrl/flannel:v0.10.0-amd64

echo '下载yml文件,部署flannel网络,dashboard用到'
mkdir -p $HOME/k8s/heapster ; cd $HOME/
YmlUrl=http://elven.vip/ks/k8s/oneinstall/yml
curl -s $YmlUrl/kube-flannel.yml >k8s/kube-flannel.yml
curl -s $YmlUrl/kubernetes-dashboard.yaml >k8s/kubernetes-dashboard.yaml
curl -s $YmlUrl/heapster-rbac.yaml >k8s/heapster-rbac.yaml
curl -s $YmlUrl/heapster/influxdb.yaml >k8s/heapster/influxdb.yaml
curl -s $YmlUrl/heapster/heapster.yaml >k8s/heapster/heapster.yaml
curl -s $YmlUrl/heapster/grafana.yaml >k8s/heapster/grafana.yaml

echo
echo '镜像列表'
docker images |egrep 'k8s.gcr.io|quay.io'
echo
echo "yml部署文件"
ls -l $HOME/k8s/
echo