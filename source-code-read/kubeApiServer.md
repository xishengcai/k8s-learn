###  设计图

### 主要方法功能介绍
   1. api register
   ```
   kubernets/pkg/master/master.go
   func New(c *Config)(*Master, error) {
         m.InstallAPIs(c)
   }
   ```

   2. 根据Config往APIGroupsInfo内增加组信息，然后通过InstallAPIGroups进行注册
   ```
   func (m *Master) InstallAPIs(c *Config) {
       if err := m.InstallAPIGroups(apiGroupsInfo); err != nil {
           glog.Fatalf("Error in registering group versions:%v", err)
       }
   }
   ```

   3. 转换为APIGroupVersion这个关键数据结构，然后进行注册
   ```
    func (s *GenericAPIServer) installAPIGroup(apiGroupInfo *APIGroupInfo) error {
        apiGroupVersion, err := s.getAPIGroupVersion(apiGroupInfo, groupVersion, apiPrefix)
        if err := apiGroupVersion.InstallREST(s.HandlerContainer); err != nil {
            return fmt.Errorf("Unable to setup API %v: %v", apiGroupInfo, err)
        }
    }
   ```

   4. APIGroupVersion 关键数据结构


### 主要方法跳转
    app.Run()    //cmd/kube-apiserver/apiserver.go
       CreateServerChain(runOptions, stopCh)         //cmd/kube-apiserver/app/server.go
            CreateNodeDialer(runOptions)
            kubeAPIServerConfig, sharedInformers, versionedInformers, insecureServingOptions, serviceResolver, err := CreateKubeAPIServerConfig(runOptions, nodeTunneler, proxyTransport)
            apiExtensionsConfig, err := createAPIExtensionsConfig(*kubeAPIServerConfig.GenericConfig, versionedInformers, runOptions)
            apiExtensionsServer, err := createAPIExtensionsServer(apiExtensionsConfig, genericapiserver.EmptyDelegate)
            kubeAPIServer, err := CreateKubeAPIServer(kubeAPIServerConfig, apiExtensionsServer.GenericAPIServer, sharedInformers, versionedInformers)
                aggregatorServer, err := aggregatorConfig.Complete().NewWithDelegate(delegateAPIServer)

            kubeAPIServer.GenericAPIServer.PrepareRun()
            apiExtensionsServer.GenericAPIServer.PrepareRun()
            aggregatorConfig, err := createAggregatorConfig(*kubeAPIServerConfig.GenericConfig, runOptions, versionedInformers, serviceResolver, proxyTransport)
            aggregatorServer, err := createAggregatorServer(aggregatorConfig, kubeAPIServer.GenericAPIServer, apiExtensionsServer.Informers)






