## istio 最佳实践

### 下载最新istio安装包
    curl -L https://git.io/getIstio | sh -

### 安装istio
    cd istio-1.0.4
    kubectl create -f install/kubernetes/istio-demo-auth.yaml

### 安装示例bookinfo
   安装bookinfo
   ```kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)```
   修改ingressgateway为Nodeport方式暴露服务
   ```kubectl edit svc istio-ingressgateway -n istio-system```

   修改服务器暴露方式
   type: LoadBlancer  --> type: NodePort
   ```kubectl edit svc istio-ingressgateway -n istio-system```

### 创建网关
   kubectl create -f samples/bookinfo/networking/bookinfo-gateway.yaml
   在浏览器中访问页面 http://nodeip:31380/productpage
   刷新页面可以发现reviews v1, v2, v3后端不停的轮询

### 配置路由
   - 实验一： 只访问reviews：v1
   创建路由规则(我们上面用的是istio-demo-auth, 所以这里需要使用启用了mTLS的路由规则)
   ```
   istioctl create -f samples/bookinfo/networking/destination-rule-all-mtls.yaml
   istioctl create -f samples/bookinfo/networking/virtual-service-all-v1.yaml
   ```

   您应该可以看到 Bookinfo 应用程序的 productpage 页面。 请注意， productpage 页面显示的内容中没有评分星级，
   这是因为 reviews:v1 服务不会访问 ratings 服务。

   查看路由规则
   ```istioctl get virtualservices -o yaml```

   ```
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      annotations:
        kubectl.kubernetes.io/last-applied-configuration: |
          {"apiVersion":"networking.istio.io/v1alpha3","kind":"VirtualService","metadata":{"annotations":{},"name":"bookinfo","namespace":"default"},"spec":{"gateways":["bookinfo-gateway"],"hosts":["*"],"http":[{"match":[{"uri":{"exact":"/productpage"}},{"uri":{"exact":"/login"}},{"uri":{"exact":"/logout"}},{"uri":{"prefix":"/api/v1/products"}}],"route":[{"destination":{"host":"productpage","port":{"number":9080}}}]}]}}
      creationTimestamp: null
      name: bookinfo
      namespace: default
      resourceVersion: "1516859"
    spec:
      gateways:
      - bookinfo-gateway
      hosts:
      - '*'
      http:
      - match:
        - uri:
            exact: /productpage
        - uri:
            exact: /login
        - uri:
            exact: /logout
        - uri:
            prefix: /api/v1/products
        route:
        - destination:
            host: productpage
            port:
              number: 9080
    ---
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      creationTimestamp: null
      name: details
      namespace: default
      resourceVersion: "1517399"
    spec:
      hosts:
      - details
      http:
      - route:
        - destination:
            host: details
            subset: v1
    ---
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      creationTimestamp: null
      name: productpage
      namespace: default
      resourceVersion: "1517379"
    spec:
      hosts:
      - productpage
      http:
      - route:
        - destination:
            host: productpage
            subset: v1
    ---
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      creationTimestamp: null
      name: ratings
      namespace: default
      resourceVersion: "1517381"
    spec:
      hosts:
      - ratings
      http:
      - route:
        - destination:
            host: ratings
            subset: v1
    ---
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      creationTimestamp: null
      name: reviews
      namespace: default
      resourceVersion: "1608948"
    spec:
      hosts:
      - reviews
      http:
      - route:
        - destination:
            host: reviews
            subset: v1
    ---
   ```

   - 实验二： 将来自特定用户的请求路由到 reviews:v2
   通过将来自 productpage 的流量路由到 reviews:v2 实例，为测试用户 “jason” 启用 ratings 服务。
   ``` istioctl replace -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml```
   在 productpage 网页上以用户 “jason” 身份登录。
   您现在应该在每次评论旁边看到评分（1-5颗星）。 请注意，如果您以任何其他用户身份登录，您将会继续看到 reviews:v1 版本服务，
   即不包含星级评价的页面。
   ```istioctl get virtualservice reviews -o yaml```

   ```
   apiVersion: networking.istio.io/v1alpha3
   kind: VirtualService
   metadata:
     name: reviews
     ...
   spec:
     hosts:
     - reviews
       http:
     - match:
       - headers:
           end-user:
             exact: jason
       route:
       - destination:
           host: reviews
           subset: v2
     - route:
       - destination:
           host: reviews
           subset: v1
    ```

