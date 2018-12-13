### data flow

### istio inject
   手动注入
   ``` istioctl  kube-inject  -f  <your-app>.yaml -o <your-app-addEnvoy>.yaml```
   注入后更改的文件部分
   - Annotation
   ```
   metadata:
     annotations:
       sidecar.istio.io/status: '{"version":"ebf16d3ea0236e4b5cb4d3fc0f01da62e2e6265d005e58f8f6bd43a4fb672fdd","initContainers":["istio-init"],"containers":["istio-proxy"],"volumes":["istio-envoy","istio-certs"],"imagePullSecrets":null}'
   ```
   - istio-proxy

   - arg
   proxy sidecar
   configPath: /etc/istio/proxy
   binaryPath: /usr/local/bin/envoy
   serviceCluster: details
   discoveryAddress: istio-pilot.istio-system:15007
   proxyAdminPort: 15000
   ```
   - args:
     - proxy
     - sidecar
     - --configPath
     - /etc/istio/proxy
     - --binaryPath
     - /usr/local/bin/envoy
     - --serviceCluster
     - details
     - --drainDuration
     - 45s
     - --parentShutdownDuration
     - 1m0s
     - --discoveryAddress
     - istio-pilot.istio-system:15007
     - --discoveryRefreshDelay
     - 1s
     - --zipkinAddress
     - zipkin.istio-system:9411
     - --connectTimeout
     - 10s
     - --proxyAdminPort
     - "15000"
     - --controlPlaneAuthPolicy
     - NONE
   ```
### envoy


### destination rule


### virtual service
