#!/usr/bin/python3
#auther:don 2023/02/03
# coding:utf-8
import os
import time
import subprocess
#定义服务器，用户名、密码、数据库名称和备份的路径
DB_HOST = 'localhost'
DB_USER = 'root'
DB_USER_PASSWD = 'mtDOuNNCLsL1P\$2yVAkL12123'
DB_NAME1 = 'video_center'
DB_NAME2 = 'app_center_private'
DB_NAME3= 'app_center_public'
DB_SOCKET = '/home/mysql_6603/mysql.sock'
BACKUP_PATH = '/home/data/dbbackup/mysql/'

DATETIME = time.strftime('%Y%m%d-%H%M')
TODAYBACKUPPATH = BACKUP_PATH + DATETIME

print("开始创建备份文件夹,如果不存在就创建....")
#创建备份文件夹
if not os.path.exists(TODAYBACKUPPATH):
        os.makedirs(TODAYBACKUPPATH)

# 创建备份函数
def run_backup():
    dumpcmd = "/home/mysql_6603/bin/mysqldump -u" + DB_USER + " -p" + DB_USER_PASSWD + " -S" + DB_SOCKET + " --master-data=2" + " --single-transaction" +"  --databases" + " " + DB_NAME1 +" " + DB_NAME2 + " " + DB_NAME3 + " > " + TODAYBACKUPPATH + "/" + "all" + ".sql"
    print(dumpcmd)
    os.system(dumpcmd)

#执行压缩的函数
def run_tar():
        compress_file = TODAYBACKUPPATH + ".tar.gz"
        compress_cmd = "tar -czvf " +compress_file+" "+DATETIME
        os.chdir(BACKUP_PATH)
        os.system(compress_cmd)
        print("压缩已完成......")
        #删除备份文件夹
        remove_cmd = "rm -rf "+TODAYBACKUPPATH
        os.system(remove_cmd)

#删除历史的备份
def cleanstore():
    command = "find %s -type d -mtime +5 |xargs rm -rf" %BACKUP_PATH
    subprocess.call(command, shell=True)

## 开始备份数据库
if __name__ == '__main__':
    run_backup()
    run_tar()
    cleanstore()
