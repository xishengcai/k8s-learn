### kubernetes1.12 单节点脚本安装

### enviroment require
    centos  7.2+
    maskter  2CPU 4G
    node     1CPU 2G
    https://m.aliyun.com/act/team1111/#/share?params=N.sYMbMeiEQg.k3lfqn3q  0.5折阿里云优惠购
    
### image require
    
### install order
   components
   ```
    docker  17.03
    kubeadm 1.12.0
    kubelet 1.12.0
    kubernetes-cni 0.6.0-0
    network pulg (defalut flannel)
    helm    v2.11.0
  ```

  run step
  ```
  sh step_1--install-docker.sh
  sh step_2--install-k8s-init.sh
  sh step_3--install-kubeadm.sh
  sh step_4--install-k8s-master.sh
  ```
    
### kubernetse slave install
    创建 token
    kubeadm token create --print-join-command
    
    查询token
    kubeadm token list
    
    创建子节点
    kubeadm join 172.16.71.242:6443 \ 
                 --token go9hr3.h8tgy2n21g1y2di1 \
                 --discovery-token-ca-cert-hash  \
                 sha256:87baac22927bd020cb864098bbeeafac076c8aa54a3aaae41fdb837feb4e9dc7
 
### kubectl 命令自动补全
    yum install -y bash-completion
    chmod +x /usr/share/bash-completion/bash_completion
    /usr/share/bash-completion/bash_completion
    source /usr/share/bash-completion/bash_completion
    source <(kubectl completion bash)

         
   
    