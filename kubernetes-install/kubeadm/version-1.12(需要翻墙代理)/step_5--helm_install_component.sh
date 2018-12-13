#!/usr/bin/env bash

# 1.安装helm
echo "Helm由客户端命helm令行工具和服务端tiller组成，Helm的安装十分简单。 下载helm命令行工具到master节点"
#wget https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
tar -zxvf ../soft_package/helm-v2.11.0-linux-amd64.tar.gz
mv -f ./linux-amd64/helm /usr/local/bin/
rm -rf ./linux-amd64

git clone https://github.com/XishengCai/charts.git

# 2. tiller-deploy
# 因为Kubernetes APIServer开启了RBAC访问控制，所以需要创建tiller使用的service account: tiller并分配合适的角色给它。
# 详细内容可以查看helm文档中的Role-based Access Control。 这里简单起见直接分配cluster-admin这个集群内置的ClusterRole给它
helm del $(helm ls --all | awk '{print $1}'| grep -v NAME) --purge

echo "apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system" > tiller_rbac.yaml

kubectl create -f tiller_rbac.yaml
sleep 10

# 接下来使用helm部署tiller
helm init --service-account tiller --skip-refresh
# 查看
kubectl get pod -n kube-system -l app=helm

# 3.ingress
kubectl label node `hostname` node-role.kubernetes.io/edge=
echo "controller:
  service:
    externalIPs:
      - 192.168.61.11
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule

defaultBackend:
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule" > ingress-nginx.yaml

sed -i 's/192.168.61.11/'$(ifconfig  eth0 | grep "inet" | awk '{print $2}')'/g' ingress-nginx.yaml

helm install ./charts/stable/nginx-ingress \
-n nginx-ingress \
--namespace ingress-nginx  \
-f ingress-nginx.yaml

# 4.prometheus

# 5.dashboard
# 当使用Ingress将HTTPS的服务暴露到集群外部时，需要HTTPS证书，这里将*.frognew.com的证书和秘钥配置到Kubernetes中。
# 后边部署在kube-system命名空间中的dashboard要使用这个证书，因此这里先在kube-system中创建证书的secret
kubectl create secret tls frognew-com-tls-secret --cert=/etc/kubernetes/pki/ca.crt --key=/etc/kubernetes/pki/ca.key -n kube-system
helm del --purge kubernetes-dashboard
cat <<EOF > kubernetes-dashboard.yaml
ingress:
  enabled: true
  hosts:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/secure-backends: "true"
  tls:
    - secretName: frognew-com-tls-secret
      hosts:
rbac:
  clusterAdminRole: true
EOF

helm install ./charts/stable/kubernetes-dashboard \
-n kubernetes-dashboard \
--namespace kube-system  \
-f kubernetes-dashboard.yaml


kubectl describe -n kube-system secret/`kubectl -n kube-system get secret | grep kubernetes-dashboard-token | awk '{print $1}'`
# 6.metrics-server

echo "args:
- --logtostderr
- --kubelet-insecure-tls" > metrics-server.yaml

helm install ./charts/stable/metrics-server \
-n metrics-server \
--namespace kube-system \
-f metrics-server.yaml

echo  "kubectl edit configmap coredns -n kube-system"
echo   "kubectl get --raw \"/apis/metrics.k8s.io/v1beta1/nodes\""

# 7.Influxdb
echo "
ingress:
  enabled: true
  tls: false
  hostname:
  path: /influxdb_web"> Influxdb.yaml
helm install ./charts/stable/influxdb \
            -n kube-influxdb \
            --namespace kube-system


# 8.prometheus-s
git clone https://github.com/coreos/prometheus-operator.git
helm install ./prometheus-operator/helm/prometheus-operator \
             --name prometheus-operator \
             --set rbacEnable=true \
             --namespace=monitoring


# 9.prometheus
    helm install ./prometheus-operator/helm/prometheus \
                 --name prometheus \
                 --set serviceMonitorsSelector.app=prometheus \
                 --set ruleSelector.app=prometheus \
                 --namespace=monitoring

# 10.alertmanager
helm install ./prometheus-operator/helm/alertmanager \
             --name alertmanager \
             --namespace=monitoring

# 11.grafana
helm install ./prometheus-operator/helm/grafana \
             --name grafana \
             --namespace=monitoring

#NOTES:
#1. Get your 'admin' user password by running:
#   kubectl get secret --namespace monitoring grafana-grafana -o jsonpath="{.data.password}" | base64 --decode ; echo
#
#2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:
#   grafana.monitoring.svc.cluster.local
#   Get the Grafana URL to visit by running these commands in the same shell:
#     export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana" -o jsonpath="{.items[0].metadata.name}")
#     kubectl --namespace monitoring port-forward $POD_NAME 3000
