#!/bin/bash
# made by Elven , 2018-5-1
# Blog http://www.cnblogs.com/elvi/p/8976305.html

#check
[[ $UID -ne 0 ]] && { echo "Must run in root user !";exit; }

echo '# 基础配置#
#关闭防火墙
#关闭Selinux
#关闭Swap
#内核配置
'
#防火墙#
systemctl stop firewalld &>/dev/null
systemctl disable firewalld &>/dev/null
[[ -f /etc/init.d/ufw ]] && { ufw disable;}
[[ -f /etc/init.d/iptables ]] && { /etc/init.d/iptables stop; }
#关闭Selinux
setenforce  0 &>/dev/null
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config
#关闭Swap
swapoff -a
sed 's/.*swap.*/#&/' /etc/fstab &>/dev/null
#内核#
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl -p /etc/sysctl.d/k8s.conf &>/dev/null
echo "sysctl -p /etc/sysctl.d/k8s.conf" >>/etc/profile
echo "#myset
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
* soft  memlock  unlimited
* hard memlock  unlimited
">> /etc/security/limits.conf

#hosts

##############################