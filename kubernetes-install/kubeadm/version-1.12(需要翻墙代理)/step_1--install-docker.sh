#!/usr/bin/env bash
#docker17.03 安装：
# made by Caixisheng  Fri Nov 9 CST 2018
# https://www.cnblogs.com/waken-captain/

#移除旧的docker
yum remove docker docker-common container-selinux docker-selinux docker-engine
yum remove $(yum list installed | grep docker | awk '{print $1}')
rpm -e $(rpm -q docker-ce)

#安装工具
yum install -y yum-utils

#添加仓库
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache
yum install -y policycoreutils-python


#下载并安装docker-ce-selinux
# wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
rpm -ivh ../soft_package/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm

#查看docker-ce版本并且安装
yum list docker-ce --showduplicates | sort -r     #查看所有所有版本包
yum -y install docker-ce-17.03.2.ce


#修改启动文件
cat <<EOF > /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target firewalld.service

[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8118" "HTTPS_PROXY=http://127.0.0.1:8118"
Type=notify
ExecStart=/usr/bin/dockerd  -H unix:///var/run/docker.sock -H tcp://0.0.0.0:6071 --insecure-registry=0.0.0.0/0
ExecReload=/bin/kill -s HUP
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

echo -n  "do ou has been installed proxy"
echo -n  "你是否已经安装了穿墙代理 -> [y/n] "
read  proxy
if [[ $proxy == "y" ||  $proxy == "Y" ]]; then
   echo -n "please enter you http:proxy ip:port, example 127.0.0.1:8118  "
   echo
   read port
   sed -i 's/8118/'''$port'''/g' /usr/lib/systemd/system/docker.service
else
   sed -i 's/Environment=/#Environment=/g' /usr/lib/systemd/system/docker.service
fi

#通过配置文件修改文件系统和数据目录
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
	"storage-driver": "overlay2",
	"storage-opts": [
        "overlay2.override_kernel_check=true"
	],
	"graph": "/data/docker"
}
EOF

#default native.cgroupdriver=systemd
## 如果要开启tls
#	https://blog.csdn.net/laodengbaiwe0838/article/details/79340805
#	--service
#		-H=tcp://0.0.0.0:2376 # 修改端口号为2376
#		-H=unix:///var/run/docker.sock
#		--tlsverify
#		--tlscacert=/etc/docker/ca.pem
#		--tlscert=/etc/docker/server-cert.pem
#		--tlskey=/etc/docker/server-key.pem

#启动
systemctl daemon-reload
systemctl enable docker
systemctl restart docker


#校验
docker info
docker version
