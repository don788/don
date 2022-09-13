#!/bin/bash
func() {
	yum install -y yum-utils \
        device-mapper-persistent-data \
        lvm2
         yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
           yum -y install docker-ce
cat <<EOF >/etc/docker/daemon.json
{
 "registry-mirrors":[ "https://registry.docker-cn.com" ] 
}
EOF
systemctl start docker
systemctl enable docker

}
func1(){
var=$(ps -ef | grep docker | awk '{print $2}' |sed -n '1p')
return $var
echo "this is dockerpid"
}
func1
dockerpid=`echo $?` 
if [ -n "$dockerpid" ];then
 	echo -e "\033[31m ------此机器上有docker,开始安装 卸载--------- \033[0m"
yum remove docker \
 docker-client \
 docker-client-latest \
 docker-common \
 docker-latest \
 docker-latest-logrotate \
 docker-logrotate \
 docker-selinux \
 docker-engine-selinux \
  docker-engine
  yum install -y yum-utils \
device-mapper-persistent-data \
 
 func
  
else 
        result=$(func)
	echo "\033[37m -------重新安装docker! \033[0m---------"

fi
#####安装vpn#######################
docker pull kylemanna/openvpn
OVPN_DATA="$1"
IP="$2"
mkdir ${OVPN_DATA}
docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u tcp://${IP}
docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full CLIENTNAME nopass
docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient windows ${OVPN_DATA}/windows.ovpn
docker run --name openvpn -v ${OVPN_DATA}:/etc/openvpn -d -p 1194:1194 --privileged kylemanna/openvpn
