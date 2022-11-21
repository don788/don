installRedis5(){
        ###判断是否已经运行redis，如果已经有实例运行，不安装
        ps aux | grep -i "redis"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                cd /tmp
                

                unzip redis5.zip
                #初始化YUM源
                yum -y install gcc tcl
                #安装ruby
                yum install gcc-c++ patch readline readline-devel zlib zlib-devel -y
                yum install libyaml-devel libffi-devel openssl-devel make -y
                yum install bzip2 autoconf automake libtool bison iconv-devel sqlite-devel -y

                #安装redis
                echo "install redis"
                cp -r /tmp/redis /usr/local/

                #修改防火墙配置
                #echo "config the iptables"
                #sed -i '/-A INPUT -i lo -j ACCEPT/a-A INPUT -p tcp --dport 6379 -j ACCEPT' /etc/sysconfig/iptables
                #/etc/init.d/iptables save
                #chkconfig iptables on
                #etc/init.d/iptables restart
                #创建相关目录:
                mkdir -p  /data/logs/redis/6379  /data/redis/6379

                #创建redis服务
                cp /tmp/redis_6379 /etc/init.d/
                chmod +x /etc/init.d/redis_6379
                chmod +x /usr/local/redis/src/*
				sed 's#AUTH='3K6GzOiVYF5k'#AUTH='3K6GzOiVYF5k'#' /etc/init.d/redis_6379 -i 
                #redis优化
                #sed -i "s/tcp-keepalive 300/tcp-keepalive 0/" /etc/redis/6379.conf
                #sed -i "/# maxmemory-policy noeviction/a\maxmemory-policy volatile-lru" /etc/redis/6379.conf
                echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled">>/etc/rc.local
                echo "vm.overcommit_memory = 1" >>/etc/sysctl.conf
                /sbin/ldconfig
                echo "/usr/local/gacp/gperftools/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
                ldconfig
                #添加redis 到开机启动
                ln -s /usr/local/redis/src/redis-cli /usr/bin/
                ln -s /usr/local/redis/src/redis-server /usr/bin/
                chkconfig redis_6379 on
                #启动redis
                echo "start redis now"
                redis-server /usr/local/redis/6379.conf


        else
        echo "redis already installed"
        fi

}
installRedis5
