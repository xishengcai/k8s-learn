#!/bin/bash


# 生成根秘钥及证书
$ openssl req -x509 -sha256 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 356 -nodes -subj '/CN=Launcher LStack Authority'

# 生成服务器密钥，证书并使用CA证书签名
openssl req -new -newkey rsa:4096 -keyout server.key -out server.csr -nodes -subj '/CN=tls-test.com'
openssl x509 -req -sha256 -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

# 生成客户端密钥，证书并使用CA证书签名
openssl req -new -newkey rsa:4096 -keyout client.key -out client.csr -nodes -subj '/CN=tls-test.com'
openssl x509 -req -sha256 -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out client.crt

# 生成p12
openssl pkcs12 -export -clcerts -inkey client.key -in client.crt -out client.p12 -name "k8s-client"

kubectl delete secret my-certs -n ingress-nginx

kubectl -n ingress-nginx create secret generic my-certs \
--from-file=tls.crt=server.crt \
--from-file=tls.key=server.key \
--from-file=ca.crt=ca.crt

