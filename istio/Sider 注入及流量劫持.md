[原文地址](https://mp.weixin.qq.com/s?__biz=MzIwNDIzODExOA==&mid=2650166191&idx=1&sn=61810a8c1788f8d8d73b8ff6f886c98b&chksm=8ec1cfe6b9b646f027476c67c25432b5679130df5cc6caefb568834f7f89588c92b92a7c30be&scene=21#wechat_redirect)
### 相关概念
- sidecar: 容器的应用模式之一, Service Mesh 架构的一种实现方式
- init Container: Pod中的一种专用容器,在容器启动之前做一些初始化配置
- iptables:流量劫持是通过 iptables 转发实现的。

   kubectl get pod productpage-v1-697f57cdfd-gm7g5  -o=jsonpath='{..spec.containers[*].name}'
   productpage istio-proxy
   productpage 即应用容器， istio-proxy 即 Envoy 代理的 sidecar 容器。另外该 Pod 中实际上还运行过一个 Init 容器，
   因为它执行结束就自动终止了，所以我们看不到该容器的存在。

### Init 容器解析
    Init 容器的启动入口是 /usr/local/bin/istio-iptables.sh 脚本，该脚本的用法如下
    