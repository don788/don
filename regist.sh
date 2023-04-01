#!/bin/bash

# 从文件中读取域名列表
for i in `cat domain.txt`
do
  registrar_url=$(whois $i | grep "Registrar WHOIS Server" |awk '{print $NF}')
  if [ "$registrar_url" = "whois.jumi.com" ];then 
  # 使用 grep 命令搜索匹配的域名
  #matching_domains=$(grep -iw "$registrar_url" domains.txt)

  # 如果有匹配的域名，则输出
    echo "Domains registered jumi.com $i" >> jumi.com.txt
  else 
    echo "Domain not jumi.com"
  fi



done
