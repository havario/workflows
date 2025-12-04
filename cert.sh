#!/bin/bash

# 到期时间
openssl x509 -in /data/docker_data/nginx/certs/honeok.com_fullchain.pem -noout -dates
echo $(( ( $(openssl x509 -in /data/docker_data/nginx/certs/honeok.com_fullchain.pem -noout -enddate | cut -d= -f2 | xargs -I{} date -d "{}" +%s) - $(date +%s) ) / 86400 ))

# 证书签发者
openssl x509 -in /data/docker_data/nginx/certs/honeok.com_fullchain.pem -noout -issuer

# 证书使用域名
openssl x509 -in /data/docker_data/nginx/certs/honeok.com_fullchain.pem -text -noout | grep -A1 "Subject Alternative Name" | tail -n1 | xargs

# 公钥类型和长度
openssl x509 -in /data/docker_data/nginx/certs/honeok.com_fullchain.pem -text -noout | grep "Public-Key"
