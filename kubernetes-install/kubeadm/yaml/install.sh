#!/usr/bin/env bash

MyUrl=registry.cn-shanghai.aliyuncs.com/alik8s
docker pull $MyUrl/flannel:v0.10.0-amd64
docker tag $MyUrl/flannel:v0.10.0-amd64  quay.io/coreos/flannel:v0.10.0-amd64
docker rmi $MyUrl/flannel:v0.10.0-amd64

docker pull registry.cn-shanghai.aliyuncs.com/alik8s/heapster-grafana-amd64:v4.4.3
docker pull registry.cn-shanghai.aliyuncs.com/alik8s/heapster-influxdb-amd64:v1.3.3
docker pull registry.cn-shanghai.aliyuncs.com/alik8s/heapster-amd64:v1.4.2

docker tag registry.cn-shanghai.aliyuncs.com/alik8s/heapster-grafana-amd64:v4.4.3 k8s.gcr.io/heapster-grafana-amd64:v4.4.3
docker tag registry.cn-shanghai.aliyuncs.com/alik8s/heapster-influxdb-amd64:v1.3.3 k8s.gcr.io/heapster-influxdb-amd64:v1.3.3
docker tag registry.cn-shanghai.aliyuncs.com/alik8s/heapster-amd64:v1.4.2 k8s.gcr.io/heapster-amd64:v1.4.2


kubectl create -f ./dashboard/
kubectl create -f ./flannel/
kubectl create -f ./grafana//
kubectl create -f ./influxdb/
kubectl create -f ./prometheus/

echo
echo -e "\033[32mdashboard登录令牌,保存到$HOME/k8s.token.dashboard.txt\033[0m"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') |awk '/token:/{print$2}' >$HOME/k8s.token.dashboard.txt

