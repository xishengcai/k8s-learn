# proxy
由于墙的存在,无法拉取镜像,建议科学上网
下面介绍怎么搭建代理

### server
在境外代理机器上通过pip安装shadowsocks,并且启动服务端程序
[如果您还没有代理机,可以选择在阿里云上购买一台香港服务器,虽然有点贵，但是稳定不，不会被墙]https://promotion.aliyun.com/ntms/yunparter/invite.html?userCode=j7wyhezj)
```
yum -y install epel-release python-pip automake
pip install shadowsocks
 ```

   ```
cat <<EOF> /etc/shadowsocks.conf
{
        "server":"0.0.0.0",
        "server_port": 12345 ,
        "local_port":1080,
        "password":"yourpassword",
        "timeout":600,
        "method":"aes-256-cfb",
        "workers":1
}
EOF
   ```

   ```
   ssserver -c /etc/shadowsocks.conf -d start //后台启动
   ```

    
### client
   在境内服务器安装一个代理转换程序privoxy,将shaodows加密的流支持http协议
```
yum -y install epel-release python-pip shadowsocks
```

   编写配置文件,将server_ip修改为你境外的服务器ip地址,
   12345是境外服务器shadowSocket暴露的端口,
   local_port是你本地shadowSocket监听的端口
```
cat <<EOF> /etc/shadowsocks.conf
{
        "server":"server_ip",
        "server_port":12345 ,
        "local_port":1080,
        "password":"yourpassword",
        "timeout":600,
        "method":"aes-256-cfb",
        "workers":1
}
EOF
```

    启动shadow sockets 客户端服务
```
sslocal  -c /etc/shadowsocks.conf -d start //后台启动
```

Autoconf 及 Automake 这两套工具来协助我们自动产生 Makefile文件
```
yum -y install gcc wget autoconf
```

  下载privoxy,用于将shadowSocket加密的数据转换为http协议,
  如果无法下载,clone本项目,我已下载好
```
wget http://www.privoxy.org/sf-download-mirror/Sources/3.0.26%20%28stable%29/privoxy-3.0.26-stable-src.tar.gz
tar -zxvf privoxy-3.0.26-stable-src.tar.gz
cd privoxy-3.0.26-stable
```

编译安装
```
useradd privoxy
autoheader && autoconf
./configure
make && make install
```

  在文件/usr/local/etc/privoxy/config中找到下面两行,去掉注释
```
forward-socks5t   /               127.0.0.1:1080
listen-address  127.0.0.1:8118
```
    
启动协议转换代理：
`privoxy --user privoxy /usr/local/etc/privoxy/config  # 以用户privoxy 的身份运行指定配置文件`
    
### 配置环境变量
export http_proxy=http://127.0.0.1:8118 
export https_proxy=http://127.0.0.1:8118 
export ftp_proxy=http://127.0.0.1:8118

### windows client
[windows 小飞机代理工具](https://github.com/shadowsocks/shadowsocks-windows/releases)


### 总结
```
服务端（socket5 协议）  - - - - -  客户端 （socket5协议）
									|
									|
						  privoxy（socket5 和 http协议互转）
									|
									|
                             具体应用curl, yum,wget等
```
