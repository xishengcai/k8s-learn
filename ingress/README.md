## ingress
   Ingress, added in Kubernetes v1.1, exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.
   Traffic routing is controlled by rules defined on the ingress resource.

### ingress-controller
   * Contour is an Envoy based ingress controller provided and supported by Heptio.
   * F5 Networks provides support and maintenance for the F5 BIG-IP Controller for Kubernetes.
   * HAProxy based ingress controller jcmoraisjr/haproxy-ingress which is mentioned on the blog post HAProxy Ingress Controller for Kubernetes. HAProxy Technologies offers support and maintenance for HAProxy Enterprise and the ingress controller jcmoraisjr/haproxy-ingress.
   * Istio based ingress controller Control Ingress Traffic.
   * Kong offers community or commercial support and maintenance for the Kong Ingress Controllerfor Kubernetes.
   * NGINX, Inc. offers support and maintenance for the NGINX Ingress Controller for Kubernetes.
   * Traefik is a fully featured ingress controller (Let’s Encrypt, secrets, http2, websocket), and it also comes with commercial support by Containous.

   You may deploy any number of ingress controllers within a cluster. When you create an ingress, you should annotate each ingress
   with the appropriate ingress-class to indicate which ingress controller should be used if more than one exists within your cluster.
   If you do not define a class, your cloud provider may use a default ingress provider

### ingress resource

   ```
   apiVersion: extensions/v1beta1
   kind: Ingress
   metadata:
     name: test-ingress
     annotations:
       nginx.ingress.kubernetes.io/rewrite-target: /
   spec:
     rules:
     - http:
         paths:
         - path: /testpath
           backend:
             serviceName: test
             servicePort: 80
   ```

   As with all other Kubernetes resources, an ingress needs apiVersion, kind, and metadata fields.
   For general information about working with config files, see deploying applications, configuring containers, managing resources.
   Ingress frequently uses annotations to configure some options depending on the ingress controller,
   an example of which is the rewrite-target annotation. Different ingress controller support different annotations.
   Review the documentation for your choice of ingress controller to learn which annotations are supported.

   The ingress spec has all the information needed to configure a loadbalancer or proxy server. Most importantly,
   it contains a list of rules matched against all incoming requests. Ingress resource only supports rules for directing HTTP traffic

### ingress rule
   Each http rule contains the following information:
   * host
   An optional host. In this example, no host is specified, so the rule will apply to all inbound HTTP traffic through the IP
    address that will be connected. If a host is provided, for example: foo.bar.com, the rules will apply on to that host.
   * path
   a list of paths (e.g.: /testpath) each of which has an associated backend defined with a serviceName and servicePort.
    Both the host and path must match the content of an incoming request before the loadbalancer will direct traffic to
    the referenced service.
   * backend
   A backend is a combination of service and port names as described in the services doc. HTTP (and HTTPS) requests to the
   ingress matching the host and path of the rule will be sent to the listed backend.
   A default backend is often configured in an ingress controller that will service any requests that do not match a path in the spec
   example:
   ```
   apiVersion: extensions/v1beta1
   kind: Ingress
   metadata:
     name: name-virtual-host-ingress
   spec:
     rules:
     - host: first.bar.com
       http:
         paths:
         - backend:
             serviceName: service1
             servicePort: 80
     - host: second.foo.com
       http:
         paths:
         - backend:
             serviceName: service2
             servicePort: 80
     - http:
         paths:
         - backend:
             serviceName: service3
             servicePort: 80
   ```


### default backend
   An ingress with no rules sends all traffic to a single default backend. The default backend is typically a configuration option
   of the ingress controller and is not specified in your ingress resources.

   If none of the hosts or paths match the HTTP request in the ingress objects, the traffic is routed to your default backend

### tls

   *基于修改的openssl.cnf与ca证书生成ingress ssl证书*
   *生成秘钥*
   ```
   openssl genrsa -out ingress.key 2048
   ```

   *生成csr文件*
   ```
   openssl req -new -key ingress.key -out ingress.csr -subj "/CN=nginx-svc-tls" -config openssl.cnf
   ```

   *生成证书*
   ```
   openssl x509 -req -in ingress.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out ingress.crt -days 3650 -extensions v3_req -extfile openssl.cnf
   ```

   *创建 secret*
   ```
   kubectl create secret tls ingress-tls --cert=/etc/kubernetes/pki/ca.crt --key=/etc/kubernetes/pki/ca.key -n kube-system
   ```

### annotations
   You can add these Kubernetes annotations to specific Ingress objects to customize their behavior.

   !!! tip Annotation keys and values can only be strings. Other types, such as boolean or numeric values must be quoted, i.e.
   "true", "false", "100".

   !!! note The annotation prefix can be changed using the --annotations-prefix command line argument, but the default
   is nginx.ingress.kubernetes.io, as described in the table below.

   https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md

#### this script usage
   #### You have a working environment.
   ```
   k8s 1.12
   can pull foreign images
   ```

   *create ingress-tls-sercret, svc(jenkins) ,ingress-controller(rbac), ingress-controller, default-backend, ingress*
   ```
   kubectl create secret tls ingress-tls --cert=/etc/kubernetes/pki/ca.crt --key=/etc/kubernetes/pki/ca.key -n kube-system
   git clone https://github.com/XishengCai/k8s-learn.git
   kubectl create -f ingress
   kubectl create -f prometheus
   ```

   *visit jenkins with ingress1*
   *http, https, ip visit*
   ```
   curl localhost:40001
   curl localhost:40002
   ```

   *visit jenkins with ingress2*
   *domain name visit*
   ```
   curl -H 'Host:jenkins.cai' http://172.31.146.1
   curl -H 'Host:prometheus.cai' http://172.31.146.1 or curl --resolve prometheus.cai:80:172.31.146.1 http://prometheus.cai

   ```

#### Reference connection
   * [kubernetes 官方文档](https://kubernetes.io/docs/concepts/services-networking/ingress)
   * [ingress 部署1](http://blog.51cto.com/newfly/2060587)
   * [ingress 部署2](https://www.cnblogs.com/netonline/archive/2018/04/18/8877324.html)
   * [rbac 角色控制](https://mp.weixin.qq.com/s?__biz=MzI3MzQ3NDMzNw==&mid=2247483765&idx=1&sn=aa0fe555392d7c767757a9d5b80b69ad&chksm=eb23f73bdc547e2db6ef5af5cd218b0bee8f9e58ca8ba4d948b6a3ed3261822d83c60c331739&scene=7#rd)
   * [jenkins 安装](https://yq.aliyun.com/articles/622521)
   * [ingress-nginx project](https://github.com/kubernetes/ingress-nginx)
   * [annotations](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md)
