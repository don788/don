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
				/home/mysql_6603/bin/mysqld_safe --defaults-file=/home/mysql_6603/my.cnf --user=mysql &
                                echo "done,now you can use mysql6603 -P 6603 -S /home/mysql_6603/mysql.sock -uroot -p to login"

}


installMysql5_7
installMysql5_7_bin
