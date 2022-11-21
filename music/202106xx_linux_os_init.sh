#!/bin/bash
#changed on Feb27 by paolo,更新zabbix安装脚本，加入filebeat安装
#changed on Dec25 by paolo  PHP加入7.3版本
#changed on Dec 18 by paolo PHP 升级到7.2.25
#changed on Dec16 by paolo,加入php5安装方式，msf合并到php安装中
#changed on Oct2 by paolo ,优化zabbix安装
#changed on Aug 20 by paolo , 修改防火墙格式，添加公钥
#changed on Aug 4 by paolo ,添加python3 安装，C语言环境支持
#changed on june 9 by paolo , 修改内核参数，允许跳过初始化安装对应脚本
#changed on june 6 by paolo , change nginx to version 2.3 ,disable some unuse software
#changed on june 1 by paolo ,lastest change: fix ssh port ,add php-msf and mysql-bin install
#change on may 24,2019 ,lastest change:php install 
#请在/tmp目录下执行脚本！！
##current dir
SHELL_FOLDER=$(dirname $(readlink -f "$0"))
###常用软件
commonSoft=('vim'  'wget'  'unzip' )
installCommonSoft(){
        for i in ${commonSoft[@]}
        do
                echo "installing common soft..."
                yum install -y ${i} > /dev/null
        done
}
###检测操作系统版本
getOSVersion(){
        grep "CentOS Linux release 7" /etc/redhat-release* > /dev/null 2>&1
        retCode=$?
        if [ $retCode -eq 0 ]
        then
                echo "RHEL7"
        else
                echo "RHEL6"
        fi
}

###操作系统常用配置
osBaseConfig7(){
        wget  ftp://204.236.174.29:51210/centos_init/CentOS7_init/* --user=inituser --password='Q+Q_C.net@20$1=9'
        #!/bin/sh
        read -p "请输入远程端口：" port
        unzip /tmp/file.zip
        systemctl stop firewalld
        systemctl disable firewalld
        systemctl stop NetworkManager
        systemctl disable NetworkManager

        DATE=`date +%Y%m%H`

        #deluser
        userdel uucp
        userdel operator
        userdel games
        userdel gopher
        userdel ftp

        #mkdir -p  /etc/yum.repos.d/bak
        #mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/

        #\cp /tmp/file/repo/* /etc/yum.repos.d/
        /usr/bin/yum clean all
        /usr/bin/yum update -y
        sleep 1
        #安装git
        curl https://setup.ius.io | sh
        yum -y install git2u
        #安装常用工具
        /usr/bin/yum -y install tree httping iptables-services psmisc tree httping net-tools iftop mtr nload epel-release ntp lsof htop nmap iotop telnet iptraf vim-enhanced  logrotate 
        /usr/bin/yum -y install ntsysv bind-utils sysstat rsync irqbalance microcode_ctl  dstat net-snmp bzip2 openssh-clients 
        /usr/bin/yum -y install zlib zlib-devel  openssl-devel openssl python-devel libcurl-devel gcc
        #安装python3
        yum install python36u -y
        ln -s /bin/python3.6 /bin/python3
        yum install python36u-pip -y
        ln -s /bin/pip3.6 /bin/pip3

        mkdir -p /usr/local/gacp/worksh

        #\cp -rf  /tmp/file/jail.conf /etc/fail2ban/jail.conf
        #add qqc user
        /usr/sbin/useradd qqc
        usermod -G wheel qqc
        echo "0@m}dukd0B03" | passwd qqc --stdin
        #cp public key
        mkdir /home/qqc/.ssh/
        cp /tmp/file/authorized_keys /home/qqc/.ssh/
        chmod 600 /home/qqc/.ssh/authorized_keys
        chown -R qqc.qqc /home/qqc/.ssh/
        sed -i 's/^%wheel/#&/' /etc/sudoers
        echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" >>/etc/sudoers


        \cp /tmp/file/worksh/* /usr/local/gacp/worksh/
        mkdir -p /data/check
        chmod +x /usr/local/gacp/worksh/*.sh
        echo 'syntax on' > /root/.vimrc
        echo "session required pam_limits.so" >>/etc/pam.d/login

        \cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        hwclock --systohc --localtime
        echo 'ZONE="Asia/Shanghai"' >/etc/sysconfig/clock
        systemctl restart rsyslog crond
        \cp /tmp/file/root /var/spool/cron/root
        sed -i '/log_rotate.sh/s/^/#/g' /var/spool/cron/root
        sed -i '/php_log.sh/s/^/#/g' /var/spool/cron/root
        sed -i '/del_3day_php_logs.sh/s/^/#/g' /var/spool/cron/root
        sed -i '/del_5day_nginx_logs.sh/s/^/#/g' /var/spool/cron/root
        \cp /tmp/file/selinux /etc/sysconfig/selinux
        setenforce 0

        \cp /tmp/file/limits.conf /etc/security/limits.conf
        mv /etc/security/limits.d/20-nproc.conf /etc/security/limits.d/20-nproc
        \cp /tmp/file/sysctl.conf /etc/sysctl.conf
        echo 819200 > /proc/sys/fs/inotify/max_user_watches
        /sbin/sysctl -p

        for sun in `chkconfig --list|grep 3:on|awk '{print $1}'`;do chkconfig --level 2345 $sun off;done
        for sun in crond irqbalance network sysstat sshd rsyslog iptables;do chkconfig --level 2345 $sun on;done

        \cp /tmp/file/iptables /etc/sysconfig/iptables
        sed -i "s/30000/$port/g" /etc/sysconfig/iptables
        sed -i '1h;1!H;$!d;x;s/.*30000[^\n]*/&\n-A INPUT -m comment --comment "for exvid"  -m state --state NEW -m tcp -p tcp -s 223.119.68.154 --dport 30000 -j ACCEPT/' /etc/sysconfig/iptables
        sed -i '1h;1!H;$!d;x;s/.*30000[^\n]*/&\n-A INPUT -m comment --comment "for exvid"  -m state --state NEW -m tcp -p tcp -s 180.193.191.122 --dport 30000 -j ACCEPT/' /etc/sysconfig/iptables

        \cp /tmp/file/cloudflare_whitelist.txt /etc/sysconfig/
        \cp /tmp/file/wangsu_whitelist.txt /etc/sysconfig/

        \cp /tmp/file/sshd_config /etc/ssh/sshd_config
        DATE=`date +%Y%m%H`

        ssh_cf="/etc/ssh/sshd_config" 
        sed -i "s/Port 30000/Port $port/" $ssh_cf
        sed -i "s/#MaxAuthTries 6/MaxAuthTries 3/" $ssh_cf
        #sed -i "s/#UseDNS yes/UseDNS no/" $ssh_cf
        #sed -i "/X11Forwarding yes/d" $ssh_cf
        #sed -i "s/#X11Forwarding no/X11Forwarding no/g" $ssh_cf
        #sed -i "s/#PrintMotd yes/PrintMotd no/g" $ssh_cf
        #sed -i "s/#PrintLastLog yes/PrintLastLog no/g" $ssh_cf
        #sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' $ssh_cf
        #sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' $ssh_cf
        #sed -i '$aAllowUsers qqc' $ssh_cf
        #vim
        sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
        sed -i "9 s/^/alias dstat='dstat -cdlmnpsy'\n/" /root/.bashrc
        sed -i "10 s/^/alias grep='grep --color=auto'\n\n/" /root/.bashrc
        echo 'syntax on' > /root/.vimrc
        #保存历史记录
        echo "shopt -s histappend" >> ~/.bashrc
        echo "export HISTFILESIZE=100000" >> ~/.bashrc
        echo "export HISTSIZE=10000" >> ~/.bashrc
        echo 'export HISTCONTROL=ignoreboth' >> ~/.bashrc

        source /root/.bashrc

        #清空信息信息为了安全
        ISSUE=/etc/issue
        ISSUE_NET=/etc/issue.net
        RELEASE=/etc/redhat-release

        cp $ISSUE $ISSUE.$DATE
        cp $ISSUE_NET $ISSUE_NET.$DATE
        cp $RELEASE $RELEASE.$DATE

        >$ISSUE
        >$ISSUE_NET
        >$RELEASE

        #重要文件加锁 --不可修改
        #chattr +i /etc/sudoers
        #chattr +i /etc/shadow
        #chattr +i /etc/passwd
        #chattr +i /etc/grub.conf
        #关闭不必要服务
        systemctl stop postfix
        systemctl disable postfix
        systemctl stop chronyd 
        systemctl disable chronyd

        #重要文件加锁 --不可删除
        chattr +a /var/log/messages
        chattr +a /var/log/wtmp

        chmod +x /etc/rc.d/rc.local 

        systemctl enable iptables.service
        systemctl restart iptables.service
        systemctl enable sshd.service
        systemctl restart sshd.service

}

osBaseConfig6(){
        #!/bin/bash
        wget  ftp://204.236.174.29:51210/centos_init/CentOS6_init/* --user=inituser --password='Q+Q_C.net@20$1=9'
        read -p "请输入远程端口：" port
        #解压缩startup.tar.gz包
        cd /tmp && unzip centos6_startup.zip

        #初始化YUM源
        #mkdir /etc/yum.repos.d/backup/
        #mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/
        #cp -ap /tmp/centos6_startup/file/*.repo /etc/yum.repos.d/
        #/bin/rpm --import ./file/RPM-GPG-KEY.dag.txt
        #/bin/rpm --import ./file/RPM-GPG-KEY-CentOS-6
        #/usr/bin/yum clean all
        /usr/bin/yum makecache

        #下载工具及时间同步工具
        /usr/bin/yum install -y wget
        /usr/bin/yum install -y ntp
        ntpdate -d cn.pool.ntp.org
        date

        #修改时区
        echo 'ZONE="Asia/Shanghai"' >/etc/sysconfig/clock
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

        echo "##### update server time #####" >> /var/spool/cron/root
        echo "*/10 * * * * /usr/sbin/ntpdate cn.pool.ntp.org > /dev/null 2>&1 && /sbin/clock -w > /dev/null 2>&1" >> /var/spool/cron/root
        echo "" >> /var/spool/cron/root
        echo "##### history #####" >> /var/spool/cron/root
        echo "*/5 * * * * /usr/local/gacp/worksh/history.sh > /dev/null 2>&1" >> /var/spool/cron/root
        echo "" >> /var/spool/cron/root
        echo "##### Logs #####" >> /var/spool/cron/root
        #echo "00 00 * * * /usr/local/gacp/worksh/del_100day_before_logs.sh > /dev/null 2>&1" >> /var/spool/cron/root
        #echo "00 00 * * * /usr/local/gacp/worksh/log_rotate.sh > /dev/null 2>&1" >> /var/spool/cron/root
        echo "" >> /var/spool/cron/root

        #下载必要系统工具
        /usr/bin/yum install -y lsof htop nmap iotop httping telnet iptraf iftop vim-enhanced logrotate ntsysv bind-utils sysstat irqbalance microcode_ctl dstat net-snmp rsync openssh-clients

        #selinux is disabled
        sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config 
        echo "selinux is disabled,you must reboot!"
        setenforce 0

        #vim
        sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
        sed -i "9 s/^/alias dstat='dstat -cdlmnpsy'\n/" /root/.bashrc
        sed -i "10 s/^/alias grep='grep --color=auto'\n\n/" /root/.bashrc
        echo 'syntax on' > /root/.vimrc

        source ~/.bashrc

        mv /etc/security/limits.d/90-nproc.conf /etc/security/limits.d/90-nproc

        #file size
        echo 'ulimit -SHn 65535' >> /etc/rc.local
        ###set ulimit
        echo "start set ulimit"
        echo "*                     soft     nofile             1024000" >> /etc/security/limits.conf
        echo "*                     hard     nofile             1024000" >> /etc/security/limits.conf

        ###set sysctl
        sysconf="/etc/sysctl.conf"
        ###脚本向/etc/sysctl.conf写入配置前插入识别字符串INITOSSCRIPTINSEREDIT,脚本执行时如果检测到文件中包含此字符串，跳过此步骤
        grep "INITOSSCRIPTINSEREDIT" ${sysconf} > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                echo "start set sysctl"
                echo "###INITOSSCRIPTINSEREDIT" >> ${sysconf}
                echo "net.ipv4.tcp_tw_reuse = 1" >> ${sysconf}
                echo "net.ipv4.tcp_tw_recycle = 1" >> ${sysconf}

                echo "net.ipv4.tcp_syn_retries = 1" >> ${sysconf}
                echo "net.ipv4.tcp_fin_timeout = 30" >> ${sysconf}
                echo "net.ipv4.tcp_keepalive_time = 600" >> ${sysconf}
                echo "net.ipv4.tcp_syncookies = 1" >> ${sysconf}
                echo "net.ipv4.ip_local_port_range = 1024 65535" >> ${sysconf}
                echo "net.ipv4.tcp_max_syn_backlog = 65535" >> ${sysconf}
                echo "net.ipv4.tcp_max_tw_buckets = 65535" >> ${sysconf}
                echo "net.core.wmem_default = 8388608" >> ${sysconf}
                echo "net.core.rmem_default = 8388608" >> ${sysconf}
                echo "net.core.rmem_max = 16777216" >> ${sysconf}
                echo "net.core.wmem_max = 16777216" >> ${sysconf}
                echo "net.core.netdev_max_backlog = 131070" >> ${sysconf}
                echo "net.core.somaxconn = 304800" >> ${sysconf}
                echo "net.netfilter.nf_conntrack_max = 120000" >> ${sysconf}
                echo "net.netfilter.nf_conntrack_tcp_timeout_established = 3600" >> ${sysconf}
                echo "net.ipv4.tcp_tw_recycle = 1" >> ${sysconf}
                echo "fs.file-max = 10000000" >> ${sysconf}
                echo "fs.nr_open = 10000000" >> ${sysconf}
                echo "net.ipv4.tcp_keepalive_probes = 3" >> ${sysconf}
                echo "net.ipv4.tcp_keepalive_intvl = 15" >> ${sysconf}

                /sbin/sysctl -p
        else
                echo "sysctl has configured,skip..."
        fi

 
        #init
        for sun in `chkconfig --list|grep 3:on|awk '{print $1}'`;do chkconfig --level 2345 $sun off;done
        for sun in crond irqbalance network sysstat sshd rsyslog iptables;do chkconfig --level 2345 $sun on;done

        DATE=`date +%Y%m%H`

        #add qqc user
        /usr/sbin/useradd qqc
        usermod -G wheel qqc
        echo "0@m}dukd0B03" | passwd qqc --stdin
        #cp public key
        cp /tmp/centos6_startup/file/authorized_keys /home/qqc/.ssh/
        chmod 600 /home/qqc/.ssh/authorized_keys
        sed 's/^%wheel/#&/' /etc/sudoers
        echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" >>/etc/sudoers

        #ssh
        ssh_cf="/etc/ssh/sshd_config" 

        cp $ssh_cf $ssh_cf.$DATE 
        sed -i "s/#Port 22/Port $port/" $ssh_cf
        sed -i "s/#UseDNS yes/UseDNS no/" $ssh_cf
        sed -i "/X11Forwarding yes/d" $ssh_cf
        sed -i "s/#X11Forwarding no/X11Forwarding no/g" $ssh_cf
        sed -i "s/#PrintMotd yes/PrintMotd no/g" $ssh_cf
        sed -i "s/#PrintLastLog yes/PrintLastLog no/g" $ssh_cf
        sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' $ssh_cf
        sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' $ssh_cf
        #sed -i '$aAllowUsers qqc' $ssh_cf
        /etc/init.d/sshd reload

        #iptables添加规则放通端口
        \cp /tmp/centos6_startup/file/iptables /etc/sysconfig/iptables
        sed -i "s/30000/$port/g" /etc/sysconfig/iptables
        /etc/init.d/iptables restart

        #清空信息信息为了安全
        ISSUE=/etc/issue
        ISSUE_NET=/etc/issue.net
        RELEASE=/etc/redhat-release

        cp $ISSUE $ISSUE.$DATE
        cp $ISSUE_NET $ISSUE_NET.$DATE
        cp $RELEASE $RELEASE.$DATE

        >$ISSUE
        >$ISSUE_NET
        >$RELEASE

        #snmp
        snmp_cf="/etc/snmp/snmpd.conf"
        cp $snmp_cf $snmp_cf.$DATE
        rm -rf $snmp_cf
        cp -a ./etc/snmpd.conf $snmp_cf

        #deluser
        userdel uucp
        userdel operator
        userdel games
        userdel gopher
        #disable unuse software
        systemctl stop postfix
        systemctl disable postfix
		systemctl stop chronyd 
		systemctl disable chronyd

        #防爆破登录
        #yum install -y fail2ban

        #mv /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.$DATE
        #cp -ap ./file/jail.conf /etc/fail2ban/

        mkdir /usr/local/gacp/worksh -p
        cp -ap /tmp/centos6_startup/file/worksh/*  /usr/local/gacp/worksh/

}

####install zabbix agent
installZabbixAgent(){
    kernel_release="$(uname -r)"
    if [[ "$kernel_release" =~ ^3|^5 ]]; then
        curl -sSL https://0vj6.github.io/sh/zabbix/zabbix4.centos7.sh | bash -s init agent 4.4
    elif [[ "$kernel_release" =~ ^2 ]]; then
        curl -sSL https://0vj6.github.io/sh/zabbix/zabbix4.centos6.sh | bash -s init agent 4.4
    fi
    usermod -a -G root zabbix
    rm -f /etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf
    service zabbix-agent stop
    mv  /etc/zabbix /etc/zabbix.bak
    git clone --depth=1 https://2c39fb5cf5656f1607d77f8a49ca819721adeddc@git.sp85xf.com/jasper/zabbix.git /etc/zabbix
    cp /etc/zabbix.bak/zabbix_agentd.conf /etc/zabbix/
    sed -i "s/Server=zabbix_server/Server=zabbix.server.revyd6lm/;s/ServerActive=zabbix_server/ServerActive=zabbix.server.revyd6lm/" /etc/zabbix/zabbix_agentd.conf
    grep -vE "^$|^#|59.188.25.205|127.0.0.1|::1" /etc/hosts | awk '{print $1}' > /etc/zabbix/scripts/next/ping_config.txt && echo "http://127.0.0.1:6666/s" > /etc/zabbix/scripts/nginx/status.config.txt
    ps -ef | grep -v grep | grep mongodb | awk '{print "MONGO_PORT=\""$10"\""}' > /etc/zabbix/scripts/mongodb/mongodb.config
    rm -fr /etc/zabbix.bak
    if [[ "$kernel_release" =~ ^3|^5 ]]; then
        systemctl restart zabbix-agent
        systemctl enable zabbix-agent
        systemctl status zabbix-agent
    elif [[ "$kernel_release" =~ ^2 ]]; then
        service zabbix-agent restart
        chkconfig zabbix-agent on
        service zabbix-agent status
    fi
    #filebeat
    yum -y install https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.2-x86_64.rpm
    systemctl stop filebeat
    mv /etc/filebeat /etc/filebeat.bak
    git clone --depth=1 https://2c39fb5cf5656f1607d77f8a49ca819721adeddc@git.sp85xf.com/jasper/filebeat.git /etc/filebeat
    rm -fr /etc/filebeat.bak
    sed -i "s/BEAT_LOG_OPTS=-e/BEAT_LOG_OPTS=" /usr/lib/systemd/system/filebeat.service
    service filebeat restart 
    chkconfig filebeat on
    service filebeat status

}

installTengine23(){
        ###判断是否已经运行nginx，如果已经有实例运行，不安装
        ps aux | grep -i "nginx: master process"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                wget  ftp://204.236.174.29:51210/nginx_install/2.3-centos7/* --user=inituser --password='Q+Q_C.net@20$1=9'
                PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
                #install dependence packages
                yum install -y pcre pcre-devel zlib zlib-devel openssl openssl-devel glibc-headers gcc-c++

                #mkdir 
                mkdir -p /usr/local/gacp
                mkdir -p /home/logs/nginx/{access,error}

                #copy nginx start/stop script
		mv /tmp/nginx.service /usr/lib/systemd/system/
		mv /tmp/nginx /etc/init.d
		systemctl daemon-reload
		chmod +x /etc/init.d/nginx
		
		#unarchive tengine-2.3
		unzip tengine2.3.zip
		mv tengine2.3/* /usr/local/gacp/
                mv /tmp/basic_status.conf /usr/local/gacp/nginx/conf/vhost.d/
                mkdir -p /usr/local/gacp/nginx/logs
                chmod +x /usr/local/gacp/nginx/sbin/nginx
                ln -s /usr/local/gacp/nginx/sbin/nginx /bin/nginx

                #make user and privileges
                useradd -M -s /sbin/nologin nginx
                chown -R nginx:nginx /usr/local/gacp/nginx
                chown -R nginx:nginx /home/logs/nginx
                   echo '/home/logs/nginx/**/*log {
                        create 0644 nginx nginx
                        daily
                        rotate 7
                        missingok
                        notifempty
                        compress
                        delaycompress
                        sharedscripts
                        postrotate
                        /bin/kill -USR1 `cat /usr/local/gacp/nginx/conf/nginx.pid 2>/dev/null` 2>/dev/null || true
                        endscript
                    }' >> /etc/logrotate.d/nginx


                logrotate -f /etc/logrotate.d/nginx
                systemctl restart rsyslog crond

                #ldconfig
                echo "/usr/local/gacp/gperftools/lib" > /etc/ld.so.conf.d/extend.conf
                echo "/usr/local/gacp/lib" >> /etc/ld.so.conf.d/extend.conf
                ldconfig

                #add chkconfig
                chkconfig nginx on

                #start nginx
                service nginx start
        fi
}

installTengine22_centos6(){
        ###判断是否已经运行nginx，如果已经有实例运行，不安装
        ps aux | grep -i "nginx: master process"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                wget  ftp://204.236.174.29:51210/nginx_install/2.3-centos7/* --user=inituser --password='Q+Q_C.net@20$1=9'
                #!/bin/bash
                PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
                #install dependence packages
                yum install -y pcre pcre-devel zlib zlib-devel openssl openssl-devel glibc-headers gcc-c++

                #mkdir 
                mkdir -p /usr/local/gacp
                mkdir -p /data/logs/nginx/{access,error}

                #unarchive tengine-2.2_re.tar.gz
                #tar -vxf /tmp/tenginx.tar.gz -C /usr/local/gacp
                unzip tengine2.2.zip
		mv tengine2.2/*  /usr/local/gacp/

                #make user and privileges
                useradd -M -s /sbin/nologin nginx
                chown -R nginx:nginx /usr/local/gacp/nginx
                chown -R nginx:nginx /data/logs/nginx

                #ldconfig
                echo "/usr/local/gacp/gperftools/lib" > /etc/ld.so.conf.d/extend.conf
                echo "/usr/local/gacp/libunwind/lib" >> /etc/ld.so.conf.d/extend.conf
                ldconfig

                #copy nginx start/stop script
                cp /tmp/nginx /etc/init.d
                chmod +x /etc/init.d/nginx
                chmod +x /usr/local/gacp/nginx/sbin/nginx
                ln -s //usr/local/gacp/nginx/sbin/nginx /bin/nginx

                cat << EOF >> 1.txt
                    /home/logs/nginx/**/*log {
                        create 0644 nginx nginx
                        daily
                        rotate 7
                        missingok
                        notifempty
                        compress
                        delaycompress
                        sharedscripts
                        postrotate
                        /bin/kill -USR1 `cat /usr/local/gacp/nginx/conf/nginx.pid 2>/dev/null` 2>/dev/null || true
                        endscript
                    }
EOF


                logrotate -f /etc/logrotate.d/nginx
                systemctl restart rsyslog crond

                #enable zabbix
                echo "http://127.0.0.1:6666/s" > /etc/zabbix/scripts/nginx/status.config.txt

                #add chkconfig
                chkconfig nginx on

                #tmp
                #chmod -R 777 /tmp
                #rm -rf /tmp/*

                #start nginx
                #service nginx start
        fi
}
installPHP7_2_25(){
        ###判断是否已经运行PHP，如果已经有实例运行，不安装
        ps aux | grep -i "php-fpm: master process"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                wget  ftp://204.236.174.29:51210/php7_install/php72/* --user=inituser --password='Q+Q_C.net@20$1=9'
                yum -y install unzip
                cd /tmp && unzip php7.zip
                #初始化YUM源
                yum -y install bzip2 gcc libxslt libxslt-devel perl perl-devel
                yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel curl curl-devel openssl openssl-devel
                yum install libpng12 -y
                #安装php
                echo "install php7"
                mv /tmp/php7 /usr/local/
                mkdir -p /var/log/php-fpm/
                mkdir -p /var/run/php-fpm

                #修改防火墙配置
                echo 'export PATH=/usr/local/php7/bin:$PATH' >> /root/.bash_profile
                echo 'export PATH=/usr/local/php7/sbin:$PATH' >> /root/.bash_profile
                source /root/.bash_profile


                #创建php服务
                #cp /tmp/php-fpm /etc/init.d/
                cp /tmp/php-fpm.service /etc/systemd/system/
                #chmod +x /etc/init.d/php-fpm
                chmod +x /etc/systemd/system/php-fpm.service
                chmod +x /usr/local/php7/bin/*
                chmod +x /usr/local/php7/sbin/*

                mv /usr/bin/php /usr/bin/php.bak
                mv /usr/bin/php-cgi /usr/bin/php-cgi.bak
                mv /usr/bin/php-config /usr/bin/php-config.bak
                mv /usr/bin/phpize /usr/bin/phpize.bak
                mv /usr/bin/pear /usr/bin/pear.bak
                mv /usr/bin/peardev /usr/bin/peardev.bak
                mv /usr/bin/pecl /usr/bin/pecl.bak
                mv /usr/bin/phar /usr/bin/phar.bak
                mv /usr/bin/phar.phar /usr/bin/phar.phar.bak
                mv /usr/bin/phpdbg /usr/bin/phpdbg.bak

                ln -s /usr/local/php7/bin/* /usr/bin/

                #cat << EOF >> /etc/logrotate.d/php-fpm
                echo '/var/log/php-fpm/*log {
                    daily
                    rotate 7
                    missingok
                    notifempty
                    sharedscripts
                    compress
                    delaycompress
                    postrotate
                        CONFFILE=/usr/local/php7/etc/php-fpm.conf
                        PIDFILE=$(sed -n 's/^[[:space:]]*pid[[:space:]]*=[[:space:]]*//p' $CONFFILE)
                        /bin/kill -SIGUSR1 $(cat "$PIDFILE") 2>/dev/null || true
                    endscript
                }' >> /etc/logrotate.d/php-fpm             
                
                logrotate -f /etc/logrotate.d/nginx
                systemctl restart rsyslog crond
                
                #添加php 到开机启动
                systemctl enable php-fpm
                #chkconfig php-fpm on
                #启动php
                echo "start php now"
                #service php-fpm start

                #安装composer
                cd /tmp/
                curl -sS https://getcomposer.org/installer | php
                mv composer.phar /usr/bin/composer

                #安装php-msf
                cd /home
                wget  ftp://204.236.174.29:51210/php_msf_install/php72-msf/* --user=inituser --password='Q+Q_C.net@20$1=9'
                unzip msf-install.zip
                cd /home/msf-install
                chmod +x /home/msf-install/install_msf.sh
                /bin/bash install_msf.sh
                echo "msf7 already installed"
                rm -f /bin/php && ln -s /usr/local/php7/bin/php /bin/php
        fi
}

installPHP7_3_12(){
        ###判断是否已经运行PHP，如果已经有实例运行，不安装
        ps aux | grep -i "php-fpm: master process"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                wget  ftp://204.236.174.29:51210/php7_install/php73/* --user=inituser --password='Q+Q_C.net@20$1=9'
                yum -y install unzip
                cd /tmp && unzip php73.zip
                #初始化YUM源
                yum -y install bzip2 gcc libxslt libxslt-devel perl perl-devel
                yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel curl curl-devel openssl openssl-devel
                yum install libpng12 -y
                #安装php
                echo "install php73"
                mv /tmp/php73 /usr/local/
                mkdir -p /var/log/php-fpm73/
                mkdir -p /var/run/php-fpm73/

                #修改防火墙配置
                echo 'export PATH=/usr/local/php73/bin:$PATH' >> /root/.bash_profile
                echo 'export PATH=/usr/local/php73/sbin:$PATH' >> /root/.bash_profile
                source /root/.bash_profile
                #安装libzip
                cd /tmp
                tar xf libzip-1.5.2.tar.gz -C /home/
                cd /home/libzip-1.5.2
                mkdir build
                cd build/
                yum -y install cmake3.x86_64 
                ln -s /usr/bin/cmake3 /usr/bin/cmake
                cmake3 ..
                make -j4
                make install
				yum install libsodium -y
				yum install oniguruma - y

				

                #创建php服务
                #cp /tmp/php-fpm /etc/init.d/
                \cp /tmp/php-fpm.service /etc/systemd/system/
                #chmod +x /etc/init.d/php-fpm
                chmod +x /etc/systemd/system/php-fpm.service
                chmod +x /usr/local/php56/bin/*
                chmod +x /usr/local/php56/sbin/*

                mv /usr/bin/php /usr/bin/php.bak
                mv /usr/bin/php-cgi /usr/bin/php-cgi.bak
                mv /usr/bin/php-config /usr/bin/php-config.bak
                mv /usr/bin/phpize /usr/bin/phpize.bak
                mv /usr/bin/pear /usr/bin/pear.bak
                mv /usr/bin/peardev /usr/bin/peardev.bak
                mv /usr/bin/pecl /usr/bin/pecl.bak
                mv /usr/bin/phar /usr/bin/phar.bak
                mv /usr/bin/phar.phar /usr/bin/phar.phar.bak
                mv /usr/bin/phpdbg /usr/bin/phpdbg.bak


                ln -sf /usr/local/php56/bin/* /usr/bin/
                sed -i 's/;pm.status_path = \/status/pm.status_path = \/status/' /usr/local/php56/etc/php-fpm.d/www.conf 
                sed -i 's/;ping.path = \/ping/ping.path = \/ping/' /usr/local/php56/etc/php-fpm.d/www.conf 

                echo '
                /var/log/php-fpm/*log {
                    daily
                    rotate 7
                    missingok
                    notifempty
                    sharedscripts
                    compress
                    delaycompress
                    postrotate
                        CONFFILE=/usr/local/php73/etc/php-fpm.conf
                        PIDFILE=$(sed -n 's/^[[:space:]]*pid[[:space:]]*=[[:space:]]*//p' $CONFFILE)
                        /bin/kill -SIGUSR1 $(cat "$PIDFILE") 2>/dev/null || true
                    endscript
                }' >> /etc/logrotate.d/php-fpm
            
                
                logrotate -f /etc/logrotate.d/nginx
                systemctl restart rsyslog crond
                
                #添加php 到开机启动
                systemctl enable php-fpm
                #chkconfig php-fpm on
                #启动php
                echo "start php now"
                #service php-fpm start

                #安装composer
                cd /tmp/
                curl -sS https://getcomposer.org/installer | php
                mv composer.phar /usr/bin/composer

                #安装php-msf
                cd /home
                wget  ftp://204.236.174.29:51210/php_msf_install/php73-msf/* --user=inituser --password='Q+Q_C.net@20$1=9'
                unzip msf73-install.zip
                cd /home/msf73-install
                /bin/bash install_msf.sh
                echo "msf7 already installed"
        fi
}
installPHP5_6(){
        ###判断是否已经运行PHP，如果已经有实例运行，不安装
        ps aux | grep -i "php-fpm: master process"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
            rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
            yum install -y --enablerepo=remi --enablerepo=remi-php56 php php-fpm php-devel php-mbstring php-mcrypt php-mysqlnd php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-gd php-memcache php-xmlrpc
			./configure --prefix=/usr/local/php/ --enable-fpm --with-pgsql --with-gd --with-jpeg-dir --with-png-dir --with-zlib-dir --with-openssl \

--with-pdo_pgsql --enable-opcache --with-curl --with-mcrypt --enable-mbstring --with-iconv --enable-calendar --with-xsl --with-gettext \

--with-mhash --with-xmlrpc --enable-zip --with-mysql=shared,mysqlnd --enable-sockets --with-gd --with-freetype-dir --enable-bcmath
                #安装php-msf
                cd /tmp
                wget  ftp://204.236.174.29:51210/php_msf_install/php5-msf/* --user=inituser --password='Q+Q_C.net@20$1=9'
                unzip msf56-install.zip
                mv msf56-install /home/
                cd /home/msf56-install
                /bin/bash install_msf56.sh
                echo "msf56 already installed"
        fi
}

installMysql5_7(){
        ###判断是否已经运行mysqld，如果已经有实例运行，不安装
        ps aux | grep -i "mysqld"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                rpm -ivh https://repo.mysql.com//mysql80-community-release-el7-2.noarch.rpm
                yum install -y yum-utils
                yum-config-manager --disable mysql80-community
                yum-config-manager --enable mysql57-community
                yum install -y mysql-community-server

                systemctl start mysqld.service
                systemctl enable mysqld.service

        else
		echo "mysql already installed"
        #安装innobackupex
        cd /home
        wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/tarball/percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz
        tar xf percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz 
        cp percona-xtrabackup-2.4.4-Linux-x86_64/bin/* /usr/bin/
        fi

}

installMysql5_7_bin(){
                cd /tmp
                yum install libaio -y
                wget  ftp://204.236.174.29:51210/mysql_install/* --user=inituser --password='Q+Q_C.net@20$1=9'
				unzip mysql_6603.zip
				groupadd mysql
				useradd -r -g mysql -s /bin/false -M mysql
                                mv mysqld6603 /etc/init.d/
                                chmod +x /etc/init.d/mysqld6603
                                chkconfig mysqld6603 on
				cp -r mysql_6603 /home/
				chown -R mysql.mysql /home/mysql_6603
				ln -s /home/mysql_6603/bin/mysqld_safe /usr/bin/mysqld6603
				ln -s /home/mysql_6603/bin/mysql /usr/bin/mysql6603
				echo "#/home/mysql_6603/bin/mysqld_safe --defaults-file=/home/mysql_6603/my.cnf --user=mysql &" >>/etc/rc.local
				chmod +x /etc/rc.d/rc.local
				chmod +x /home/mysql_6603/bin/*
                                rm -fr /etc/my.cnf*
				#/home/mysql_6603/bin/mysql_install_db --defaults-file=/home/mysql_6603/my.cnf --user=mysql --basedir=/home/mysql_6603/ --datadir=/home/mysql_6603/data/
                                /home/mysql_6603/bin/mysqld --defaults-file=/home/mysql_6603/my.cnf --initialize --user=mysql --basedir=/home/mysql_6603/ --datadir=/home/mysql_6603/data/ --explicit_defaults_for_timestamp
				echo "done,now you can use mysql6603 -P 6603 -S /home/mysql_6603/mysql.sock -uroot -p to login"
                        #安装innobackupex
                cd /home
                wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/tarball/percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz
                tar xf percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz 
                cp percona-xtrabackup-2.4.4-Linux-x86_64/bin/* /usr/bin/

}

installMysql5_7_rhel6(){
        ###判断是否已经运行mysqld，如果已经有实例运行，不安装
        ps aux | grep -i "mysqld"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                rpm -ivh https://repo.mysql.com//mysql80-community-release-el6-2.noarch.rpm
                yum install -y yum-utils
                yum-config-manager --disable mysql80-community
                yum-config-manager --enable mysql57-community
                yum install -y mysql-community-server

                service mysqld start
                service mysqld on
                #安装innobackupex
                cd /home
                wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/tarball/percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz
                tar xf percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz 
                cp percona-xtrabackup-2.4.4-Linux-x86_64/bin/* /usr/bin/

        else
		echo "mysql already installed"
        fi

}

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

installRedis6(){
        ###判断是否已经运行redis，如果已经有实例运行，不安装
        ps aux | grep -i "redis"  | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]
        then
                cd /tmp
                wget  ftp://204.236.174.29:51210/redis6_install/* --user=inituser --password='Q+Q_C.net@20$1=9'

                #unzip redis5.zip
                #初始化YUM源
                yum -y install gcc tcl
                #安装ruby
                yum install gcc-c++ patch readline readline-devel zlib zlib-devel -y
                yum install libyaml-devel libffi-devel openssl-devel make -y
                yum install bzip2 autoconf automake libtool bison iconv-devel sqlite-devel -y

                #安装redis
                echo "install redis"
				wget https://download.redis.io/releases/redis-6.2.6.tar.gz
				tar xzf redis-6.2.6.tar.gz
				cd redis-6.2.6 && make
                cp -r /tmp/redis-6.2.6 /usr/local/redis
				mv /tmp/6379.conf /usr/local/redis

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

Del_script(){
	chmod +x /tmp/*linux_os_init.sh
	#rm -rf /tmp/*linux_os_init.sh
}
main(){
        echo "check OS version..."
        checkOSVersion=$(getOSVersion)
        echo ${checkOSVersion}
        if [ "${checkOSVersion}" == "RHEL7" ]
        then
                echo "os version RHEL7"
                read -p"是否进行初始化安装[y|n]: " -n 1 choice_osBaseConfig7
                printf "\n"
                read -p"是否安装zabbix[y|n]: " -n 1 choice_zabbix
                printf "\n"
                read -p"Install tengine2.3 or not[y|n]: " -n 1 choice_install_nginx
                printf "\n"
                read -p"Install php7.3.12 or not[y|n]: " -n 1 choice_install_php73
                printf "\n"
                read -p"Install php7.2.25 or not[y|n]: " -n 1 choice_install_php72
                printf "\n"
                read -p"Install 、uuu/ or not[y|n]: " -n 1 choice_install_php5
                printf "\n"
                read -p"Install mysql5.7_yum or not[y|n]: " -n 1 choice_install_mysql_yum
                printf "\n"
                read -p"Install mysql5.7_bin or not[y|n]: " -n 1 choice_install_mysql_bin
                printf "\n"
                read -p"Install redis5 or not[y|n]: " -n 1 choice_install_redis5
                printf "\n"

                installCommonSoft

                case "${choice_osBaseConfig7}" in
                        y) osBaseConfig7
                           echo "start zabbix config..." ;;
                        *) echo "skip installing osBaseConfig7...";;
                esac
                case "${choice_zabbix}" in
                        y) installZabbixAgent
                           echo "start zabbix config..." ;;
                        *) echo "skip installing zabbix...";;
                esac
                case "${choice_install_nginx}" in
                        y) installTengine23;;
                        *) echo "skip installing nginx...";;
                esac
                case "${choice_install_php73}" in
                        y) installPHP7_3_12;;
                        *) echo "skip installing PHP...";;
                esac
                case "${choice_install_php72}" in
                        y) installPHP7_2_25;;
                        *) echo "skip installing PHP...";;
                esac
                case "${choice_install_php5}" in
                        y) installPHP5_6;;
                        *) echo "skip installing PHP...";;
                esac
                case "${choice_install_mysql_yum}" in
                        y) installMysql5_7;;
                        *) echo "skip installing Mysql...";;
                esac
                case "${choice_install_mysql_bin}" in
                        y) installMysql5_7_bin;;
                        *) echo "skip installing Mysql...";;

                esac
                case "${choice_install_redis5}" in
                        y) installRedis5;;
                        *) echo "skip installing Redis...";;

                esac
                case "${choice_install_redis6}" in
                        y) installRedis6;;
                        *) echo "skip installing Redis...";;

                esac
                Del_script                
        else    
                echo "os version RHEL6"
                read -p"Install tengine2.2 or not[y|n]: " -n 1 choice_install_nginx
                printf "\n"
                read -p"Install php7.3.12 or not[y|n]: " -n 1 choice_install_php73
                printf "\n"
                read -p"Install php_msf or not[y|n]: " -n 1 choice_install_php_msf
                printf "\n"
                read -p"Install mysql5.7 or not[y|n]: " -n 1 choice_install_mysql


                installCommonSoft
                echo "start OS basic config..."
                osBaseConfig6
                installZabbixAgent


                case "${choice_install_nginx}" in
                        y) installTengine22_centos6;;
                        *) echo "skip installing nginx...";;
                esac
                case "${choice_install_php73}" in
                        y) installPHP7_3_12;;
                        *) echo "skip installing PHP...";;
                esac
                case "${choice_install_mysql}" in
                        y) installMysql5_7_rhel6;;
                        *) echo "skip installing Mysql...";;

                esac
                Del_script 


        fi
}
main
